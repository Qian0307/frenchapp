"""
Source 1: Lexique383 (http://www.lexique.org)
─────────────────────────────────────────────
Lexique383 is a free French lexical database with ~140,000 entries.
It provides: orthography, POS, gender, number, frequency (film+book),
phonetic transcription (IPA-like), lemma, etc.

We use it as the canonical word list + frequency source.
Download: http://www.lexique.org/databases/Lexique383/Lexique383.tsv
"""

import re
import logging
from pathlib import Path
from typing import Iterator, Optional

import requests
import pandas as pd
from tqdm import tqdm

from config import (
    LEXIQUE_URL, CACHE_DIR, TARGET_WORDS,
    CEFR_BANDS, POS_MAP, VALID_POS, GENDER_MAP
)

logger = logging.getLogger(__name__)

LEXIQUE_CACHE = CACHE_DIR / "Lexique383.tsv"

COLUMNS_NEEDED = [
    "ortho",        # orthographic form
    "cgram",        # grammatical category (POS)
    "genre",        # gender (m/f)
    "nombre",       # number (s/p)
    "phon",         # phonetic (IPA-like)
    "lemme",        # lemma form
    "freqlivres",   # frequency in books (per million)
    "freqfilms2",   # frequency in film subtitles
    "nbrletters",   # word length
]


def download_lexique() -> Path:
    """Download Lexique383 TSV if not already cached."""
    if LEXIQUE_CACHE.exists() and LEXIQUE_CACHE.stat().st_size > 5_000_000:
        logger.info("Using cached Lexique383: %s", LEXIQUE_CACHE)
        return LEXIQUE_CACHE

    logger.info("Downloading Lexique383 from %s …", LEXIQUE_URL)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    with requests.get(LEXIQUE_URL, stream=True, timeout=60) as r:
        r.raise_for_status()
        total = int(r.headers.get("content-length", 0))
        with open(LEXIQUE_CACHE, "wb") as f, tqdm(
            total=total, unit="B", unit_scale=True, desc="Lexique383"
        ) as bar:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)
                bar.update(len(chunk))

    logger.info("Saved to %s", LEXIQUE_CACHE)
    return LEXIQUE_CACHE


def load_lexique_df(path: Path) -> pd.DataFrame:
    """Load and pre-filter Lexique383 into a clean DataFrame."""
    logger.info("Loading Lexique383 …")
    df = pd.read_csv(path, sep="\t", low_memory=False, encoding="utf-8")

    # Keep only needed columns (graceful if some are missing)
    cols = [c for c in COLUMNS_NEEDED if c in df.columns]
    df = df[cols].copy()

    # Normalise column names
    df.rename(columns={
        "ortho":      "word",
        "cgram":      "pos",
        "genre":      "gender",
        "nombre":     "number",
        "phon":       "phon",
        "lemme":      "lemma",
        "freqlivres": "freq_books",
        "freqfilms2": "freq_films",
    }, inplace=True)

    # Drop rows without a word
    df = df[df["word"].notna() & (df["word"].str.strip() != "")]

    # Keep only lemma forms (no inflected forms)
    if "lemma" in df.columns:
        df = df[df["word"] == df["lemma"]]

    # Map POS to our enum
    df["pos_mapped"] = df["pos"].str.lower().str.strip().map(POS_MAP)
    df = df[df["pos_mapped"].isin(VALID_POS)]

    # Combined frequency (books + films, both per million)
    for col in ("freq_books", "freq_films"):
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    df["freq"] = df.get("freq_books", 0) + df.get("freq_films", 0)

    # Sort by frequency descending
    df.sort_values("freq", ascending=False, inplace=True)

    # Deduplicate on word form (keep highest freq per word)
    df.drop_duplicates(subset="word", keep="first", inplace=True)

    # Filter out non-alphabetic, very short, or very long words
    df = df[df["word"].str.match(r"^[a-zA-ZÀ-ÿœæ'\-]{2,40}$", na=False)]

    # Assign frequency rank
    df = df.reset_index(drop=True)
    df["freq_rank"] = df.index + 1

    # Assign CEFR level based on frequency rank
    df["cefr_level"] = df["freq_rank"].apply(_rank_to_cefr)

    # Map gender
    if "gender" in df.columns:
        df["gender_mapped"] = df["gender"].str.lower().str.strip().map(GENDER_MAP)
    else:
        df["gender_mapped"] = None

    logger.info("Loaded %d lemmas from Lexique383", len(df))
    return df


def _rank_to_cefr(rank: int) -> str:
    for lo, hi, level in CEFR_BANDS:
        if lo <= rank <= hi:
            return level
    return "C2"


def lexique_phonetic_to_ipa(phon: str) -> str:
    """
    Convert Lexique383 phonetic notation to approximate IPA.
    Lexique uses X-SAMPA-ish notation; we do a best-effort mapping.
    """
    if not phon or pd.isna(phon):
        return ""

    mapping = {
        # vowels
        "a":  "a",   "A":  "ɑ",   "e":  "e",   "E":  "ɛ",
        "°":  "ə",   "2":  "ø",   "9":  "œ",   "i":  "i",
        "o":  "o",   "O":  "ɔ",   "u":  "u",   "y":  "y",
        "@":  "ə",   "1":  "ɛ̃",   "5":  "ɛ̃",
        # nasal vowels (Lexique notation)
        "§":  "ɔ̃",   "&":  "ɑ̃",   "µ":  "œ̃",
        # consonants
        "p":  "p",   "b":  "b",   "t":  "t",   "d":  "d",
        "k":  "k",   "g":  "g",   "f":  "f",   "v":  "v",
        "s":  "s",   "z":  "z",   "S":  "ʃ",   "Z":  "ʒ",
        "m":  "m",   "n":  "n",   "N":  "ɲ",   "G":  "ŋ",
        "l":  "l",   "R":  "ʁ",   "j":  "j",   "w":  "w",
        "H":  "ɥ",   "x":  "x",
    }
    result = []
    for ch in str(phon):
        result.append(mapping.get(ch, ch))
    ipa = "/" + "".join(result) + "/"
    return ipa


def iter_word_entries(df: pd.DataFrame, limit: int = TARGET_WORDS) -> Iterator[dict]:
    """
    Yield normalised word entry dicts from Lexique DataFrame,
    up to `limit` entries.
    """
    count = 0
    for _, row in df.iterrows():
        if count >= limit:
            break

        word = str(row["word"]).strip()
        pos  = str(row.get("pos_mapped", "noun"))

        entry = {
            "word":       word,
            "pos":        pos,
            "gender":     row.get("gender_mapped"),
            "ipa":        lexique_phonetic_to_ipa(row.get("phon", "")),
            "freq_rank":  int(row["freq_rank"]),
            "cefr_level": row["cefr_level"],
            "freq":       float(row.get("freq", 0)),
        }
        yield entry
        count += 1

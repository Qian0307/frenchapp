"""
Formatter: merge Lexique + Wiktionary data → DB-ready dict
────────────────────────────────────────────────────────────
Output schema matches the `vocabulary` table exactly.
"""

import re
import json
import uuid
import logging
from typing import Optional

from config import VALID_POS, GENDER_MAP

logger = logging.getLogger(__name__)


def merge_entry(
    lexique:    dict,
    wiktionary: dict,
    zh_tw:      str,
) -> Optional[dict]:
    """
    Merge a Lexique word record with optional Wiktionary enrichment
    and the Traditional Chinese translation.

    Returns None if the entry should be skipped (invalid POS, etc.).
    """
    word  = lexique.get("word", "").strip()
    pos   = lexique.get("pos", "noun")

    if not word or pos not in VALID_POS:
        return None

    # ── IPA ──────────────────────────────────────────────────
    # Prefer Wiktionary IPA (cleaner); fall back to Lexique conversion
    ipa = (
        wiktionary.get("ipa") or lexique.get("ipa") or ""
    ).strip()

    # ── Gender ───────────────────────────────────────────────
    gender = (
        wiktionary.get("gender")
        or lexique.get("gender")
    )
    if gender not in {"masculine", "feminine", "neuter", "invariable"}:
        gender = None  # DB nullable

    # Only assign gender to nouns/adjectives
    if pos not in {"noun", "adjective"}:
        gender = None

    # ── Plural form ───────────────────────────────────────────
    plural = wiktionary.get("plural") if pos == "noun" else None
    if plural and plural == word:
        plural = None  # redundant

    # ── Definitions ───────────────────────────────────────────
    defs = wiktionary.get("definitions", [])
    english_trans = "; ".join(defs[:2]) if defs else _fallback_english(word)

    # ── Examples ──────────────────────────────────────────────
    examples = wiktionary.get("examples", [])

    # ── Usage notes ───────────────────────────────────────────
    usage = wiktionary.get("usage")

    # ── Translations JSONB ────────────────────────────────────
    translations: dict[str, str] = {}
    if zh_tw:
        translations["zh_tw"] = zh_tw

    # ── CEFR / rank ───────────────────────────────────────────
    cefr_level = lexique.get("cefr_level", "B1")
    freq_rank  = lexique.get("freq_rank")

    # ── Topic tags: derive from CEFR + POS (best-effort) ─────
    topic_tags: list[str] = []
    if pos == "verb":
        topic_tags.append("verbs")
    if pos in {"noun", "adjective"}:
        topic_tags.append("vocabulary")

    return {
        "id":               str(uuid.uuid4()),
        "french_word":      word,
        "english_trans":    english_trans or word,
        "translations":     translations,
        "word_class":       pos,
        "gender":           gender,
        "plural_form":      plural,
        "conjugations":     None,
        "pronunciation_ipa": ipa,
        "audio_url":        None,
        "cefr_level":       cefr_level,
        "topic_tags":       topic_tags,
        "frequency_rank":   freq_rank,
        "example_sentences": examples,
        "usage_notes":      usage,
        "memory_tip":       None,
        "related_words":    [],
        "is_active":        True,
    }


def _fallback_english(word: str) -> str:
    """Last-resort: use word itself as placeholder."""
    return word


# ── SQL generator ─────────────────────────────────────────────

def entries_to_sql(entries: list[dict], batch_size: int = 100) -> str:
    """
    Convert a list of entry dicts into a series of SQL INSERT statements.
    Uses ON CONFLICT DO NOTHING so the script is re-runnable.
    """
    lines: list[str] = []
    lines.append("-- Auto-generated vocabulary seed")
    lines.append("-- 繁體中文翻譯 stored in translations->>'zh_tw'")
    lines.append("")

    def escape(v: str) -> str:
        return str(v).replace("'", "''")

    for i in range(0, len(entries), batch_size):
        batch = entries[i : i + batch_size]
        lines.append("INSERT INTO vocabulary (")
        lines.append("  id, french_word, english_trans, translations, word_class,")
        lines.append("  gender, plural_form, pronunciation_ipa, cefr_level,")
        lines.append("  topic_tags, frequency_rank, example_sentences,")
        lines.append("  usage_notes, is_active")
        lines.append(") VALUES")

        rows = []
        for e in batch:
            gender_sql    = f"'{e['gender']}'" if e['gender']    else "NULL"
            plural_sql    = f"'{escape(e['plural_form'])}'" if e['plural_form'] else "NULL"
            ipa_sql       = f"'{escape(e['pronunciation_ipa'])}'" if e['pronunciation_ipa'] else "''"
            usage_sql     = f"'{escape(e['usage_notes'])}'" if e['usage_notes'] else "NULL"
            freq_sql      = str(e['frequency_rank']) if e['frequency_rank'] else "NULL"
            translations  = json.dumps(e['translations'], ensure_ascii=False)
            examples      = json.dumps(e['example_sentences'], ensure_ascii=False)
            tags_pg       = "{" + ",".join(e['topic_tags']) + "}"

            rows.append(
                f"  ('{e['id']}', '{escape(e['french_word'])}', "
                f"'{escape(e['english_trans'])}', "
                f"'{escape(translations)}'::jsonb, "
                f"'{e['word_class']}', "
                f"{gender_sql}, {plural_sql}, {ipa_sql}, "
                f"'{e['cefr_level']}', "
                f"'{tags_pg}', {freq_sql}, "
                f"'{escape(examples)}'::jsonb, "
                f"{usage_sql}, true)"
            )

        lines.append(",\n".join(rows))
        lines.append("ON CONFLICT (french_word, word_class, cefr_level) DO NOTHING;\n")

    return "\n".join(lines)


def entries_to_csv(entries: list[dict]) -> str:
    """
    Output entries as CSV for bulk COPY import (faster than INSERT for 20k rows).
    Columns match the INSERT above.
    """
    import csv, io
    buf = io.StringIO()
    writer = csv.writer(buf, quoting=csv.QUOTE_ALL)

    writer.writerow([
        "id","french_word","english_trans","translations","word_class",
        "gender","plural_form","pronunciation_ipa","cefr_level",
        "topic_tags","frequency_rank","example_sentences","usage_notes","is_active"
    ])

    for e in entries:
        writer.writerow([
            e["id"],
            e["french_word"],
            e["english_trans"],
            json.dumps(e["translations"],     ensure_ascii=False),
            e["word_class"],
            e["gender"]        or "",
            e["plural_form"]   or "",
            e["pronunciation_ipa"] or "",
            e["cefr_level"],
            "{" + ",".join(e["topic_tags"]) + "}",
            e["frequency_rank"] or "",
            json.dumps(e["example_sentences"], ensure_ascii=False),
            e["usage_notes"]   or "",
            "true",
        ])

    return buf.getvalue()

"""
Configuration for the French vocabulary scraper.
Copy .env.example → .env and fill in values before running.
"""
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

# ── Paths ────────────────────────────────────────────────────
BASE_DIR   = Path(__file__).parent
DATA_DIR   = BASE_DIR / "data"
CACHE_DIR  = DATA_DIR / "cache"
OUTPUT_DIR = DATA_DIR / "output"
LISTS_DIR  = DATA_DIR / "word_lists"

# ── Supabase / PostgreSQL ────────────────────────────────────
DB_URL = os.getenv("DATABASE_URL",
    "postgresql://postgres:password@localhost:54322/postgres")

# ── Scraping settings ────────────────────────────────────────
WIKTIONARY_API = "https://en.wiktionary.org/w/api.php"
WIKTIONARY_CAT = "French_lemmas"           # category to enumerate
LEXIQUE_URL    = (
    "http://www.lexique.org/databases/Lexique383/"
    "Lexique383.tsv"                        # ~140k French lemmas with freq
)

# Concurrency
ASYNC_WORKERS       = 8    # parallel Wiktionary API requests
TRANSLATE_WORKERS   = 5    # parallel translation calls
BATCH_SIZE          = 100  # words per SQL INSERT batch

# Rate limiting
WIKT_DELAY_SEC      = 0.15  # between Wiktionary requests
TRANSLATE_DELAY_SEC = 0.30  # between Deep-translator calls

# Target vocabulary size
TARGET_WORDS = 20_000

# ── CEFR frequency thresholds (Lexique rank → CEFR) ─────────
# Based on Zipf frequency bands from Lexique383
CEFR_BANDS = [
    (1,    500,   "A1"),
    (501,  2000,  "A2"),
    (2001, 5000,  "B1"),
    (5001, 10000, "B2"),
    (10001,15000, "C1"),
    (15001,999999,"C2"),
]

# ── Translation target ────────────────────────────────────────
TRANSLATION_TARGET = "zh-TW"   # 繁體中文

# ── Topic tag mapping (Lexique semantic field → tag) ─────────
CATEG_TAG_MAP = {
    "aliment":      "food",
    "animal":       "animals",
    "corps":        "body",
    "couleur":      "colours",
    "famille":      "family",
    "géographie":   "geography",
    "habit":        "clothing",
    "logement":     "housing",
    "météo":        "weather",
    "musique":      "music",
    "nature":       "nature",
    "nombre":       "numbers",
    "profession":   "work",
    "santé":        "health",
    "sport":        "sports",
    "temps":        "time",
    "transport":    "transport",
    "travail":      "work",
    "ville":        "city",
    "voyage":       "travel",
}

# ── Word class normalisation ──────────────────────────────────
POS_MAP = {
    "nom":          "noun",
    "ver":          "verb",
    "adj":          "adjective",
    "adv":          "adverb",
    "pre":          "preposition",
    "con":          "conjunction",
    "pro":          "pronoun",
    "art":          "article",
    "ono":          "interjection",
    "noun":         "noun",
    "verb":         "verb",
    "adjective":    "adjective",
    "adverb":       "adverb",
    "preposition":  "preposition",
    "conjunction":  "conjunction",
    "pronoun":      "pronoun",
    "article":      "article",
    "interjection": "interjection",
    "phrase":       "phrase",
}

# Valid word classes matching DB enum
VALID_POS = {
    "noun","verb","adjective","adverb","preposition",
    "conjunction","pronoun","article","interjection","phrase"
}

GENDER_MAP = {
    "m":  "masculine",
    "f":  "feminine",
    "ms": "masculine",
    "fs": "feminine",
    "mp": "masculine",
    "fp": "feminine",
}

"""
Source 2: English Wiktionary API
──────────────────────────────────
For each French word we fetch:
  - English definition (1–2 sentences)
  - IPA pronunciation (if better than Lexique)
  - Example sentences (French with English gloss)
  - Gender confirmation
  - Plural form (nouns)
  - Conjugation note (verbs)
  - Usage notes

API: https://en.wiktionary.org/w/api.php  (no key required, 500 req/min)
"""

import re
import json
import time
import logging
import asyncio
from typing import Optional

import aiohttp
import wikitextparser as wtp
from tenacity import retry, wait_exponential, stop_after_attempt

from config import WIKTIONARY_API, CACHE_DIR, WIKT_DELAY_SEC

logger = logging.getLogger(__name__)

WIKT_CACHE_FILE = CACHE_DIR / "wiktionary_cache.json"

# ── In-memory + file cache ────────────────────────────────────

_cache: dict[str, dict] = {}

def _load_cache() -> None:
    global _cache
    if WIKT_CACHE_FILE.exists():
        try:
            with open(WIKT_CACHE_FILE, "r", encoding="utf-8") as f:
                _cache = json.load(f)
            logger.info("Loaded %d Wiktionary cache entries", len(_cache))
        except Exception:
            _cache = {}

def _save_cache() -> None:
    WIKT_CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(WIKT_CACHE_FILE, "w", encoding="utf-8") as f:
        json.dump(_cache, f, ensure_ascii=False, indent=2)


# ── Async batch fetcher ───────────────────────────────────────

class WiktionaryFetcher:
    """
    Async fetcher for Wiktionary page wikitext.
    Uses a semaphore to stay within rate limits.
    """

    def __init__(self, session: aiohttp.ClientSession, workers: int = 8):
        self.session   = session
        self._sem      = asyncio.Semaphore(workers)
        _load_cache()

    async def fetch_many(self, words: list[str]) -> dict[str, dict]:
        """Fetch wikitext for all words concurrently. Returns {word: parsed_data}."""
        tasks = [self._fetch_one(w) for w in words]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        out = {}
        for word, result in zip(words, results):
            if isinstance(result, Exception):
                logger.debug("Wiktionary error for '%s': %s", word, result)
                out[word] = {}
            elif result:
                out[word] = result
        return out

    async def _fetch_one(self, word: str) -> dict:
        if word in _cache:
            return _cache[word]

        async with self._sem:
            await asyncio.sleep(WIKT_DELAY_SEC)
            try:
                data = await self._api_call(word)
                _cache[word] = data
                return data
            except Exception as e:
                logger.debug("Wiktionary fetch failed for '%s': %s", word, e)
                return {}

    @retry(wait=wait_exponential(min=1, max=10), stop=stop_after_attempt(3))
    async def _api_call(self, word: str) -> dict:
        params = {
            "action":   "query",
            "titles":   word,
            "prop":     "revisions",
            "rvprop":   "content",
            "rvslots":  "main",
            "format":   "json",
            "formatversion": "2",
        }
        async with self.session.get(
            WIKTIONARY_API, params=params, timeout=aiohttp.ClientTimeout(total=15)
        ) as resp:
            resp.raise_for_status()
            data = await resp.json()

        pages = data.get("query", {}).get("pages", [])
        if not pages:
            return {}

        content = (
            pages[0]
            .get("revisions", [{}])[0]
            .get("slots", {})
            .get("main", {})
            .get("content", "")
        )

        if not content:
            return {}

        return _parse_wikitext(word, content)

    def save_cache(self) -> None:
        _save_cache()
        logger.info("Saved %d Wiktionary cache entries", len(_cache))


# ── Wikitext parser ───────────────────────────────────────────

_IPA_RE    = re.compile(r"\{\{IPA\|fr\|([^}|]+)")
_GENDER_RE = re.compile(r"\{\{fr-noun\|([mf])")
_PLURAL_RE = re.compile(r"pl=([^|}]+)")
_GLOSS_RE  = re.compile(r"#\s*(.+)")

# Example: {{uxi|fr|Il mange une pomme.|He eats an apple.}}
_EXAMPLE_RE = re.compile(
    r"\{\{(?:uxi|ux|fr-usex)\|fr\|([^|]+)\|([^}]+)"
)

def _parse_wikitext(word: str, raw: str) -> dict:
    """
    Parse raw Wiktionary wikitext and extract French section data.
    Returns dict with keys: ipa, gender, plural, definitions, examples, usage.
    """
    # Find the French language section
    french_section = _extract_french_section(raw)
    if not french_section:
        return {}

    parsed = wtp.parse(french_section)

    # ── IPA ──────────────────────────────────────────────────
    ipa = ""
    m = _IPA_RE.search(french_section)
    if m:
        ipa = "/" + m.group(1).strip() + "/"

    # ── Gender ───────────────────────────────────────────────
    gender = None
    m = _GENDER_RE.search(french_section)
    if m:
        gender = "masculine" if m.group(1) == "m" else "feminine"

    # ── Plural form ──────────────────────────────────────────
    plural = None
    m = _PLURAL_RE.search(french_section)
    if m:
        plural_raw = m.group(1).strip()
        if plural_raw and plural_raw != "s":
            plural = plural_raw
        elif plural_raw == "s":
            plural = word + "s"

    # ── Definitions (English glosses) ────────────────────────
    definitions: list[str] = []
    for section in parsed.sections:
        for item in section.string.split("\n"):
            item = item.strip()
            if item.startswith("# ") and not item.startswith("#:") and not item.startswith("#*"):
                gloss = _clean_wikitext(item[2:])
                if gloss and len(gloss) > 2:
                    definitions.append(gloss)
                    if len(definitions) >= 3:
                        break

    # ── Example sentences ────────────────────────────────────
    examples: list[dict] = []
    for m in _EXAMPLE_RE.finditer(french_section):
        fr_sent = _clean_wikitext(m.group(1).strip())
        en_sent = _clean_wikitext(m.group(2).strip())
        if fr_sent and en_sent:
            examples.append({"fr": fr_sent, "en": en_sent})
        if len(examples) >= 3:
            break

    # ── Usage notes ──────────────────────────────────────────
    usage = _extract_usage_notes(french_section)

    return {
        "ipa":         ipa,
        "gender":      gender,
        "plural":      plural,
        "definitions": definitions,
        "examples":    examples,
        "usage":       usage,
    }


def _extract_french_section(raw: str) -> str:
    """Extract just the ==French== section from full wikitext."""
    lines   = raw.split("\n")
    in_fr   = False
    section = []

    for line in lines:
        if line.strip() == "==French==":
            in_fr = True
            continue
        if in_fr:
            # Next top-level language section ends the French block
            if re.match(r"^==[^=]+==\s*$", line) and line.strip() != "==French==":
                break
            section.append(line)

    return "\n".join(section)


def _clean_wikitext(text: str) -> str:
    """Remove wikitext markup, returning plain text."""
    # Remove templates {{...}}
    text = re.sub(r"\{\{[^}]*\}\}", "", text)
    # Remove links [[word|display]] → display
    text = re.sub(r"\[\[(?:[^|\]]*\|)?([^\]]+)\]\]", r"\1", text)
    # Remove bold/italic
    text = re.sub(r"'{2,3}", "", text)
    # Remove HTML tags
    text = re.sub(r"<[^>]+>", "", text)
    # Clean whitespace
    text = re.sub(r"\s+", " ", text).strip()
    # Remove trailing punctuation clutter
    text = text.rstrip(";:.,")
    return text


def _extract_usage_notes(section: str) -> Optional[str]:
    """Extract ====Usage notes==== block if present."""
    m = re.search(r"====Usage notes====\s*\n((?:.+\n?)+?)(?====|$)", section)
    if not m:
        return None
    raw = m.group(1).strip()
    cleaned = _clean_wikitext(raw)
    # Truncate to ~300 chars
    if len(cleaned) > 300:
        cleaned = cleaned[:300].rsplit(" ", 1)[0] + "…"
    return cleaned if cleaned else None

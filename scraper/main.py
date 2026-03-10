#!/usr/bin/env python3
"""
French Learning App — Vocabulary Scraper & Builder
────────────────────────────────────────────────────
Builds a 20,000+ French word database with:
  • IPA pronunciation
  • 繁體中文 (Traditional Chinese) translation
  • English definition
  • Example sentences
  • CEFR level (A1–C2)
  • Frequency rank

Usage:
    pip install -r requirements.txt
    python main.py [--limit 20000] [--output sql|csv|both] [--db]

Sources:
    1. Lexique383 (140k lemmas, freq data) → word list + freq rank
    2. English Wiktionary API → IPA, examples, usage, plural
    3. Google Translate (zh-TW) → 繁體中文
"""

import argparse
import asyncio
import json
import logging
import sys
import time
from pathlib import Path

import aiohttp
from tqdm import tqdm
from tqdm.asyncio import tqdm as async_tqdm

# ── Make config importable ────────────────────────────────────
sys.path.insert(0, str(Path(__file__).parent))

from config import (
    OUTPUT_DIR, CACHE_DIR, TARGET_WORDS,
    ASYNC_WORKERS, DB_URL, BATCH_SIZE
)
from sources.lexique    import download_lexique, load_lexique_df, iter_word_entries
from sources.wiktionary import WiktionaryFetcher
from processors.translator import TraditionalChineseTranslator, save_trans_cache
from processors.formatter  import merge_entry, entries_to_sql, entries_to_csv

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


# ────────────────────────────────────────────────────────────────
# Main pipeline
# ────────────────────────────────────────────────────────────────

async def build_vocabulary(limit: int, output_mode: str, write_db: bool) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_DIR.mkdir(parents=True, exist_ok=True)

    # ── Step 1: Download & load Lexique383 ────────────────────
    logger.info("═══ STEP 1: Lexique383 ═══")
    lexique_path = download_lexique()
    df           = load_lexique_df(lexique_path)

    lexique_entries = list(iter_word_entries(df, limit=limit))
    logger.info("Got %d candidate words from Lexique383", len(lexique_entries))

    words = [e["word"] for e in lexique_entries]

    # ── Step 2: Enrich via Wiktionary ────────────────────────
    logger.info("═══ STEP 2: Wiktionary enrichment (%d words) ═══", len(words))
    wikt_results: dict[str, dict] = {}

    connector = aiohttp.TCPConnector(limit=ASYNC_WORKERS, limit_per_host=ASYNC_WORKERS)
    async with aiohttp.ClientSession(
        connector=connector,
        headers={"User-Agent": "FrenchLearningApp/1.0 (vocabulary builder; educational)"},
    ) as session:
        fetcher = WiktionaryFetcher(session, workers=ASYNC_WORKERS)

        # Process in batches to allow periodic cache saves
        chunk = 500
        for start in range(0, len(words), chunk):
            batch  = words[start : start + chunk]
            logger.info(
                "  Wiktionary: words %d–%d / %d",
                start + 1, min(start + chunk, len(words)), len(words)
            )
            batch_res = await fetcher.fetch_many(batch)
            wikt_results.update(batch_res)
            fetcher.save_cache()  # persist after each chunk

    logger.info("Wiktionary enrichment done. %d entries with data.",
                sum(1 for v in wikt_results.values() if v))

    # ── Step 3: Traditional Chinese translation ───────────────
    logger.info("═══ STEP 3: 繁體中文 translation ═══")
    translator = TraditionalChineseTranslator()

    # Collect English definitions to translate
    en_texts: list[str] = []
    for entry in lexique_entries:
        wikt = wikt_results.get(entry["word"], {})
        defs = wikt.get("definitions", [])
        en_texts.append(defs[0] if defs else entry["word"])

    zh_map = await translator.translate_many(en_texts, desc="zh-TW")
    save_trans_cache()

    logger.info("Translation done. %d/% non-empty.",
                sum(1 for v in zh_map.values() if v), len(zh_map))

    # ── Step 4: Merge & format ───────────────────────────────
    logger.info("═══ STEP 4: Merging entries ═══")
    merged: list[dict] = []
    skipped = 0

    for lexique_entry, en_text in zip(lexique_entries, en_texts):
        word = lexique_entry["word"]
        wikt = wikt_results.get(word, {})
        zh   = zh_map.get(en_text, "")

        entry = merge_entry(lexique_entry, wikt, zh)
        if entry:
            merged.append(entry)
        else:
            skipped += 1

    logger.info(
        "Merged %d entries (skipped %d invalid). Target: %d",
        len(merged), skipped, limit
    )

    # ── Step 5: Write output ─────────────────────────────────
    logger.info("═══ STEP 5: Writing output ═══")

    if output_mode in ("sql", "both"):
        sql_path = OUTPUT_DIR / "vocabulary_20000.sql"
        sql_text = entries_to_sql(merged, batch_size=BATCH_SIZE)
        sql_path.write_text(sql_text, encoding="utf-8")
        logger.info("Wrote SQL → %s  (%.1f MB)", sql_path,
                    sql_path.stat().st_size / 1_000_000)

    if output_mode in ("csv", "both"):
        csv_path = OUTPUT_DIR / "vocabulary_20000.csv"
        csv_text = entries_to_csv(merged)
        csv_path.write_text(csv_text, encoding="utf-8")
        logger.info("Wrote CSV → %s  (%.1f MB)", csv_path,
                    csv_path.stat().st_size / 1_000_000)

    # ── Step 6: (Optional) write directly to DB ───────────────
    if write_db:
        await _write_to_db(merged)

    logger.info("═══ Done! %d vocabulary entries ready. ═══", len(merged))


async def _write_to_db(entries: list[dict]) -> None:
    """Bulk-insert entries into the running Supabase/Postgres DB."""
    try:
        import psycopg2
        from psycopg2.extras import execute_values
    except ImportError:
        logger.error("psycopg2 not installed. Run: pip install psycopg2-binary")
        return

    logger.info("Connecting to database …")
    conn = psycopg2.connect(DB_URL)
    cur  = conn.cursor()

    INSERT_SQL = """
    INSERT INTO vocabulary (
        id, french_word, english_trans, translations, word_class,
        gender, plural_form, pronunciation_ipa, cefr_level,
        topic_tags, frequency_rank, example_sentences,
        usage_notes, is_active
    ) VALUES %s
    ON CONFLICT (french_word, word_class, cefr_level) DO NOTHING
    """

    import json

    rows = []
    for e in entries:
        rows.append((
            e["id"],
            e["french_word"],
            e["english_trans"],
            json.dumps(e["translations"],      ensure_ascii=False),
            e["word_class"],
            e["gender"],
            e["plural_form"],
            e["pronunciation_ipa"],
            e["cefr_level"],
            e["topic_tags"],
            e["frequency_rank"],
            json.dumps(e["example_sentences"], ensure_ascii=False),
            e["usage_notes"],
            True,
        ))

    logger.info("Inserting %d rows …", len(rows))
    chunk = 500
    for i in tqdm(range(0, len(rows), chunk), desc="DB insert"):
        execute_values(cur, INSERT_SQL, rows[i : i + chunk])
        conn.commit()

    cur.close()
    conn.close()
    logger.info("Database insert complete.")


# ────────────────────────────────────────────────────────────────
# Entry point
# ────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build French vocabulary dataset (20,000 words, zh-TW)"
    )
    parser.add_argument(
        "--limit", type=int, default=TARGET_WORDS,
        help=f"Number of words to process (default: {TARGET_WORDS})"
    )
    parser.add_argument(
        "--output", choices=["sql", "csv", "both"], default="both",
        help="Output format (default: both)"
    )
    parser.add_argument(
        "--db", action="store_true",
        help="Also insert directly into the database (requires DATABASE_URL)"
    )
    args = parser.parse_args()

    logger.info(
        "Starting vocabulary build: %d words → %s%s",
        args.limit, args.output,
        " + DB" if args.db else ""
    )
    t0 = time.time()
    asyncio.run(build_vocabulary(args.limit, args.output, args.db))
    elapsed = time.time() - t0
    logger.info("Total elapsed: %.0f min %.0f sec", elapsed // 60, elapsed % 60)


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
# ============================================================
# French Learning App — Vocabulary Scraper Runner
# 建立 20,000 個法文單字（含繁體中文翻譯）
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── 1. Python environment ─────────────────────────────────────
if [[ ! -d ".venv" ]]; then
  echo ">>> Creating Python virtual environment..."
  python3 -m venv .venv
fi

source .venv/bin/activate

echo ">>> Installing dependencies..."
pip install -q -r requirements.txt

# ── 2. Environment variables ──────────────────────────────────
if [[ ! -f ".env" ]]; then
  cat > .env << 'ENV'
# Supabase local dev DB (supabase start)
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
ENV
  echo ">>> Created .env — edit it if needed."
fi

# ── 3. Run scraper ─────────────────────────────────────────────
LIMIT="${1:-20000}"
OUTPUT="${2:-both}"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  法文單字爬蟲啟動 / French Vocabulary Scraper    ║"
echo "║  目標單字數: $LIMIT"
echo "║  輸出格式:   $OUTPUT"
echo "╚══════════════════════════════════════════════════╝"
echo ""

python main.py --limit "$LIMIT" --output "$OUTPUT"

echo ""
echo ">>> 完成！輸出檔案位於 data/output/"
ls -lh data/output/

# ── 4. (Optional) import to DB ────────────────────────────────
if [[ "${3:-}" == "--db" ]]; then
  echo ""
  echo ">>> Importing to database..."
  python main.py --limit "$LIMIT" --output sql --db
  echo ">>> 資料庫匯入完成！"
fi

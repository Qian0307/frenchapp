# French Learning App｜法語學習應用程式

A full-stack French language learning application for Traditional Chinese speakers, covering CEFR levels A1–C2.

專為繁體中文使用者設計的全端法語學習平台，涵蓋 CEFR A1–C2 全程度。結合間隔重複閃卡、AI 生成閱讀文章、系統化文法課程與錯題本，同時提供 **Flutter 行動應用程式**與 **Next.js 網頁版**。

---

## Features｜核心功能

| Feature | 功能說明 |
|---|---|
| **Spaced Repetition Flashcards** 間隔重複閃卡 | SM-2 演算法在最佳時間點安排複習，提升記憶留存率 |
| **Daily Articles** 每日閱讀文章 | AI 依 CEFR 程度生成法文文章，點擊任意單字即可查詢 |
| **Grammar Lessons** 文法課程 | A1–C2 系統化文法講解，附互動練習題 |
| **Mistake Book** 錯題本 | 自動記錄答錯的單字，集中加強複習 |
| **Vocabulary Browser** 單字瀏覽器 | 依程度篩選瀏覽 20,000+ 單字，附真人發音 |
| **Progress Dashboard** 學習儀表板 | XP 經驗值、連續學習天數與學習統計一覽 |
| **Push Notifications** 推播通知 | 每日定時複習提醒，維持學習習慣 |
| **TTS Audio** 語音朗讀 | 每個單字與例句皆提供文字轉語音發音 |

---

## Tech Stack｜技術架構

### Mobile｜行動應用程式 (Flutter)
- **Flutter** 3.x with Dart
- **Riverpod** — 狀態管理
- **GoRouter** — 路由與頁面導航
- **Supabase Flutter** — 身份驗證 + 即時資料庫
- `just_audio` / `flutter_tts` — 音訊播放與語音合成

### Web｜網頁版 (Next.js)
- **Next.js 15** with TypeScript
- **Tailwind CSS** — 樣式設計
- **Supabase JS** — 身份驗證 + 資料存取
- 部署於 **Vercel**

### Backend｜後端 (Supabase)
- **PostgreSQL** — 主要資料庫
- **Supabase Auth** — 使用者驗證（Email + Google OAuth）
- **Supabase Edge Functions** (Deno) — 文章、閃卡、文法、單字、通知等 API
- **Supabase Storage** — 音訊檔案儲存

### Data Pipeline｜資料管線 (Python)
- 單字爬蟲 — 從 Wiktionary 與 Lexique383 抓取詞彙資料
- 文章生成器 — 使用 Claude API 依程度生成法文閱讀內容
- 音訊生成器 — 批次產生 MP3 發音檔
- 文法生成器 — 建立結構化課程與練習題
- 上傳腳本 — 將生成的 SQL 檔案匯入 Supabase 資料庫

---

## Project Structure｜專案結構

```
french_learning_app/
├── flutter_app/          # Flutter 行動應用程式
│   └── lib/
│       └── features/
│           ├── articles/     # 文章閱讀
│           ├── auth/         # 登入 / 註冊
│           ├── dashboard/    # 學習儀表板
│           ├── flashcards/   # 間隔重複閃卡
│           ├── grammar/      # 文法課程
│           └── mistake_book/ # 錯題本
├── webapp/               # Next.js 網頁版
│   └── src/app/
│       ├── (app)/
│       │   ├── articles/
│       │   ├── dashboard/
│       │   ├── flashcards/
│       │   ├── grammar/
│       │   └── mistakes/
│       └── auth/
├── backend/
│   └── supabase/
│       ├── functions/    # Edge Functions（後端 API）
│       └── migrations/   # 資料庫 Migration 腳本
├── scripts/              # 資料生成與上傳腳本 (Python)
├── scraper/              # 單字爬蟲 (Python)
├── data/                 # 原始與處理後資料
└── docs/                 # 使用說明文件
```

---

## Getting Started｜快速開始

### Prerequisites｜事前準備

- Flutter SDK >= 3.3
- Node.js >= 18
- Python >= 3.10
- Supabase CLI
- 一個 Supabase 專案

### 1. Clone the Repository｜下載專案

```bash
git clone https://github.com/Qian0307/french_learning_app.git
cd french_learning_app
```

### 2. Supabase Setup｜設定後端

```bash
cd backend
supabase link --project-ref <your-project-ref>
supabase db push        # 建立資料庫結構
supabase functions deploy  # 部署 Edge Functions
```

### 3. Flutter App｜行動應用程式

```bash
cd flutter_app
cp .env.example .env   # 填入 SUPABASE_URL 與 SUPABASE_ANON_KEY
flutter pub get
flutter run
```

### 4. Web App｜網頁版

```bash
cd webapp
cp .env.example .env.local   # 填入 NEXT_PUBLIC_SUPABASE_URL 與 NEXT_PUBLIC_SUPABASE_ANON_KEY
npm install
npm run dev
```

開啟瀏覽器前往 [http://localhost:3000](http://localhost:3000)。

### 5. Seed Data｜匯入種子資料（選用）

```bash
cd scripts
pip install -r requirements.txt
cp config.py.example config.py   # 填入 Supabase 連線資訊
python run_all.py
```

---

## CEFR Coverage｜程度涵蓋範圍

```
A1 ──── A2 ──── B1 ──── B2 ──── C1 ──── C2
入門     初級     中級     中高級   高級     精通
```

每個程度皆涵蓋：
- 分級詞彙表（合計 20,000+ 單字）
- 依程度設計的閱讀文章
- 文法課程與互動練習
- 所有單字的真人/TTS 發音

---

## Documentation｜使用說明

完整繁體中文使用說明請參閱 [`docs/`](./docs/)。

---

## License

MIT

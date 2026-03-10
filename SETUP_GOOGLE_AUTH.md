# FrenchMind 網頁 & GitHub 發布設定指南

---

## 一、建立 GitHub Repository

```bash
# 1. 在 GitHub 上建立新的 public repo（例如 french-learning-app）

# 2. 在本機初始化並推送
cd "/path/to/french_learning_app"
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/你的帳號/french-learning-app.git
git push -u origin main
```

---

## 二、設定 GitHub Secrets（必要）

GitHub Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret 名稱 | 值 | 說明 |
|-------------|-----|------|
| `SUPABASE_URL` | `https://xxx.supabase.co` | Supabase 專案 URL |
| `SUPABASE_ANON_KEY` | `eyJxxx...` | Supabase anon key |

> `GITHUB_TOKEN` 不需要手動設定，GitHub Actions 會自動提供。

---

## 三、填入你的 GitHub 帳號（網頁設定）

開啟 `web/index.html`，找到最頂部的這段程式碼並修改：

```javascript
const GITHUB_USER = 'YOUR_GITHUB_USERNAME';   // ← 改成你的 GitHub 帳號
const GITHUB_REPO = 'french-learning-app';    // ← 改成你的 repo 名稱
```

---

## 四、發布 App（觸發自動建置）

### 方法 A：推送版本 Tag（推薦）

```bash
# 確保所有改動已 commit
git add .
git commit -m "release v1.0.0"

# 打上版本 tag
git tag v1.0.0

# 推送 tag 到 GitHub（這會觸發 Actions 自動建置）
git push origin v1.0.0
```

### 方法 B：手動觸發

1. 前往 GitHub → **Actions** → **Build & Release**
2. 點選右上角 **Run workflow**
3. 填入版本號（如 `v1.0.0`）→ 點 **Run workflow**

### 建置時間預估

| 平台 | 預估時間 |
|------|----------|
| Android APK | ~5 分鐘 |
| Windows ZIP | ~8 分鐘 |
| macOS DMG | ~10 分鐘 |
| iOS IPA | ~10 分鐘 |
| 全部完成 + 建立 Release | ~15 分鐘 |

建置完成後，GitHub 會自動建立一個 Release，包含各平台下載檔案。

---

## 五、設定 Google 登入

1. 前往 https://console.cloud.google.com/
2. **API 和服務** → **憑證** → **+ 建立憑證** → **OAuth 用戶端 ID**
3. 應用程式類型：**網頁應用程式**
4. **已授權的 JavaScript 來源** 加入你的網頁網址：
   - `http://localhost:3000`（本機測試）
   - `https://你的帳號.github.io`（GitHub Pages）
   - `https://你的自訂網域.com`（自訂網域）
5. 複製 **用戶端 ID**，填入 `web/index.html`：

```html
data-client_id="123456789-abcdef.apps.googleusercontent.com"
```

---

## 六、部署網頁

### GitHub Pages（推薦，免費）

**方法 1：web/ 子目錄**
1. GitHub Repo → **Settings** → **Pages**
2. Source：`Deploy from a branch`
3. Branch：`main`，資料夾：`/web`
4. 儲存後約 1-2 分鐘即可訪問：`https://你的帳號.github.io/french-learning-app`

**方法 2：獨立 gh-pages 分支**
```bash
cd web/
git init
git add .
git commit -m "deploy"
git push --force origin HEAD:gh-pages
```

### Netlify（免費，支援自訂網域）
1. 前往 https://netlify.com → 登入
2. 拖曳 `web/` 資料夾到 Netlify 部署區
3. 完成！獲得 `https://xxx.netlify.app` 網址

### 本機測試
```bash
cd web/
python3 -m http.server 3000
# 開啟 http://localhost:3000
```

---

## 七、iOS 安裝說明（給使用者）

由於 iOS 不允許未簽名 App 直接安裝，使用者需要：

1. 在 iPhone 安裝 **AltStore**（https://altstore.io）
2. 從 GitHub Releases 下載 `.ipa` 檔
3. 在 AltStore 中選擇「My Apps」→「+」→ 選擇 IPA 檔
4. 輸入 Apple ID 完成安裝（免費，每 7 天需重新更新）

---

## 八、版本號規範

建議使用語意化版本號：

```
v主版本.次版本.修補版本
v1.0.0  ← 正式發布
v1.0.1  ← 修復 Bug
v1.1.0  ← 新增功能
v2.0.0  ← 重大更新
```

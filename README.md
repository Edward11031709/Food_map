# 黑貓飲食指南（Food_map）

黑貓飲食指南是一個以台灣餐廳、咖啡廳及在地店家為核心的飲食探索平台。使用者可以搜尋店名、餐點及地區，並依店家類型、餐期、料理、飲食需求、用餐時間與預算篩選；具有已查證座標的店家可在 OpenStreetMap 地圖上標記。

## 專案現況（MVP）

- 根目錄 index.html：單頁式前端，包含店家搜尋、分類篩選、店家詳情及清單／地圖切換。
- 地圖：Leaflet + OpenStreetMap，只有已發布且具有有效座標的店家會顯示 marker。
- 資料庫：supabase/migrations/20261116000100_create_food_guide_core.sql 定義店家、營業時間、菜單、來源追蹤與蒐集任務資料表及 RLS。
- 文件：docs/data-dictionary.md 與 docs/map.md。
- 正式 AI 開發規範：AGENTS.md；agent.md 是相容入口。

目前不放入虛構店家或測試店家。資料庫尚未確認套用 migration，前端 publishable key 尚未設定，因此網站首次載入會顯示設定提示及空狀態。

## 本機預覽

此 MVP 無需建置步驟。於 Repo 根目錄啟動靜態伺服器：

```bash
python -m http.server 8000
```

然後開啟 http://localhost:8000。

## Supabase 啟用步驟

1. 先檢查 Food_map Supabase 專案現有 schema 與 migration 歷史。
2. 在 Supabase SQL Editor 套用 supabase/migrations/20261116000100_create_food_guide_core.sql（或透過已連線的 Supabase CLI 流程套用）。
3. 執行後確認 public tables、RLS、GRANT、policies 與 Security Advisor。
4. 從 Supabase Project Settings → API Keys 取得 publishable key（sb_publishable_...），填入 index.html 的 CFG.key。
5. 絕不可把 sb_secret_...、service_role 或資料庫密碼放到 index.html、GitHub Repo 或任何前端資產。

匿名使用者僅能讀取已發布資料；不可從前端寫入正式店家資料。

## GitHub Pages

部署 workflow 位於 .github/workflows/deploy-pages.yml。請在 GitHub Repo → Settings → Pages 將 Build and deployment 設為 GitHub Actions，確認 Actions workflow 成功後才算正式上線。

預期網站網址：
https://edward11031709.github.io/Food_map/

## 地圖與授權

- 地圖底圖使用 OpenStreetMap，頁面保留 © OpenStreetMap contributors attribution。
- 遵守 https://operations.osmfoundation.org/policies/tiles/ 的 Tile Usage Policy，不大量預抓圖磚或提供離線 tiles。
- 本 MVP 不使用公共 Nominatim 做 autocomplete 或批次地址轉座標。座標必須有可追溯來源。
- 詳見 docs/map.md。

## 重要檔案

- AGENTS.md：AI Agent 的正式規範。
- agent.md：簡短相容入口。
- index.html：網站入口與目前前端互動。
- supabase/migrations/：資料庫結構與安全政策。
- docs/：資料字典及地圖規範。
- .github/workflows/deploy-pages.yml：GitHub Pages 部署流程。

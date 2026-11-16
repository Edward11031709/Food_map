# 黑貓飲食指南（Food_map）

黑貓飲食指南是一個以台灣餐廳、咖啡廳及在地店家為核心的飲食探索平台。使用者可以搜尋店名、餐點及地區，並依店家類型、餐期、料理、飲食需求、用餐時間與預算篩選；具有已查證座標的店家可在 OpenStreetMap 地圖上標記。

## 專案現況（MVP）

- 根目錄 index.html：單頁式前端，包含店家搜尋、分類篩選、店家詳情及清單／地圖切換。
- 地圖：Leaflet + OpenStreetMap，只有已發布且具有有效座標的店家會顯示 marker。
- 資料庫：核心六表及公開唯讀權限已建立；另新增 `mrt_stations`、`place_mrt_stations` 兩張捷運覆蓋表，預設每站目標 100 家。Migration 版本與 SQL 位於 `supabase/migrations/`。
- 文件：`docs/data-dictionary.md`、`docs/map.md`、`docs/design-system.md`（星空視覺設計系統）與 `docs/mrt-coverage.md`（捷運站蒐集規範）。
- 正式 AI 開發規範：AGENTS.md；agent.md 是相容入口。

目前不放入虛構店家或測試店家。Food_map Supabase 已建立六張核心資料表及兩張捷運關聯表，完成 RLS 與公開唯讀權限設定；前端已設定 publishable key，並通過資料庫層級的匿名 SELECT／關聯查詢測試。資料庫目前已有台北101/世貿站的 52 家候選店家；52 家部分查證、0 家完全查證。官方名錄支持店名與樓層，並不代表每家店的現場營業狀態已核實。未確認營業時間、價格及座標留空，不以假資料補齊。

## 品牌視覺

網站採高貴星空宇宙主題：午夜藍黑背景、低對比星點與星雲、香檳金品牌重點；各店家分類使用低飽和專屬輔色。地圖採白色簡約底圖與分類星點，保留 OpenStreetMap 署名。設計規則見 [`docs/design-system.md`](docs/design-system.md)。

## 本機預覽

此 MVP 無需建置步驟。於 Repo 根目錄啟動靜態伺服器：

```bash
python -m http.server 8000
```

然後開啟 http://localhost:8000。

## Supabase 連線與權限

- 已連線至 Food_map 專案；核心 migration 與唯讀權限強化 migration 均已套用。版本號及 SQL 分別保存在 `supabase/migrations/`。
- 前端 `index.html` 的 `CFG.url` 與 `CFG.key` 已設定為專案 URL 和 publishable key（`sb_publishable_...`）。
- `anon` 與 `authenticated` 對 `places`、`place_hours`、`menu_items`、`sources`、`place_sources` 只有 SELECT 權限；RLS 僅允許已發布店家及其相關資料可見。
- `ingestion_runs` 不授予公開角色任何表權限，且有拒絕政策。
- `mrt_stations` 與 `place_mrt_stations` 開放唯讀；只公開啟用站點及已發布店家的關聯。
- Security Advisor 已檢查，沒有安全警示。資料目前 0 筆店家，不要自行新增虛構資料。
- 新增 migration 前先檢查 Supabase 遠端 migration history，migration 檔名時間戳需與遠端版本一致。
- 絕不可把 `sb_secret_...`、service_role 或資料庫密碼放到 `index.html`、GitHub Repo 或任何前端資產。

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

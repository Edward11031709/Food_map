# 黑貓飲食指南（Food_map）

黑貓飲食指南是一個以台灣餐廳、咖啡廳、平民小吃及在地店家為核心的飲食探索平台。使用者可以搜尋店名、餐點及地區，依店家類型、餐期、料理、飲食需求、用餐時間與預算篩選；會員還可收藏店家及標記自己吃過的店。具有可靠座標的店家才會在 OpenStreetMap 地圖上標記。

## 專案現況（MVP）

- 根目錄 index.html：單頁式前端，包含搜尋、分類分組、進階篩選、店家詳情、清單／地圖切換、Email 會員登入／註冊、收藏及「我吃過」標記。
- 會員互動：Supabase Auth；favorites 與 place_visits 僅本人可讀寫；公開頁面只顯示每家店的吃過累積數，不公開會員名單。user_roles 由資料庫管理，使用者無法自行升級管理員。
- 地圖：Leaflet + OpenStreetMap，只有已發布且具有有效座標的店家會顯示 marker。
- 資料庫：核心六表及公開唯讀權限已建立；另新增 `mrt_stations`、`place_mrt_stations` 兩張捷運覆蓋表，預設每站目標 100 家。Migration 版本與 SQL 位於 `supabase/migrations/`。
- 文件：`docs/data-dictionary.md`、`docs/map.md`、`docs/design-system.md`（星空視覺設計系統）與 `docs/mrt-coverage.md`（捷運站蒐集規範）。
- 正式 AI 開發規範：AGENTS.md；agent.md 是相容入口。

目前不放入虛構店家或測試店家。Food_map Supabase 已建立核心資料表、捷運關聯表與會員互動表，RLS 及最小權限已設定。資料庫目前有台北101／世貿站（R03）83 筆候選店家關聯／100 家目標：68 家店家主檔部分查證、15 家待確認；站點關聯另有 56 筆部分查證、27 筆待確認、0 筆完全查證。第四輪新增陳記米糕、查記麵館及世貿好吃炸蛋餅 3 家，重新查核七飯 SEVEN RICE、徐記古早味水煎包、加油添醋烏醋乾麵及黃金麵線 4 家。藤香厚工豆花仍是目前唯一有可追溯店家座標的店家。R03 目前沒有可追溯的直線或步行距離欄位，83 筆關聯均不可直接宣稱位於 800 公尺範圍內；其餘 131 個官方站點主檔尚未匯入。9 家已發布店家的 last_verified_at 仍為 null，網站會顯示「尚無確認紀錄」。未確認營業時間、價格、距離及座標保持未知。

## 會員互動與隱私

- 登入／註冊由 Supabase Auth 管理，不在前端儲存密碼。
- 收藏及「我吃過」是會員私人資料；會員只能讀寫自己的記錄。
- 公開的「N 人吃過」是資料庫維護的累積數字，不公開會員名單或使用者識別資料。
- 管理員角色由資料庫受控設定，不能透過瀏覽器或 user metadata 自我提升。

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
- `anon` 與 `authenticated` 對公開店家資料只有 SELECT 權限；RLS 僅允許已發布店家及其相關資料可見。
- profiles、user_roles、favorites、place_visits 已啟用 RLS；會員只能讀取自己的 profile、role、收藏與吃過紀錄，並只能新增／刪除自己的互動資料。
- place_community_counts 只公開每家已發布店家的吃過累積數；資料庫觸發器同步計數，不公開 user_id。公開端僅有 SELECT 權限。
- `ingestion_runs` 不授予公開角色任何表權限，且有拒絕政策。
- `mrt_stations` 與 `place_mrt_stations` 開放唯讀；只公開啟用站點及已發布店家的關聯。
- 會員彙總改為唯讀資料表後，Supabase Security Advisor 檢查結果為 0 項安全警示。Performance Advisor 目前只有 11 項未使用索引 INFO，待實際流量增加後再評估，未移除索引。
- 會員系統 migration：20261116161130_create_user_accounts_and_place_community.sql、20261116161702_use_public_community_counts_projection.sql；實際版本以遠端 migration history 為準。
- 目前 Auth 尚無註冊會員。管理員角色需待使用者註冊後，以其實際註冊 Email 由資料庫端升級；不可在前端設定 admin。
- 新增 migration 前先檢查 Supabase 遠端 migration history，migration 檔名時間戳需與遠端版本一致。
- 絕不可把 `sb_secret_...`、service_role 或資料庫密碼放到 `index.html`、GitHub Repo 或任何前端資產。

## GitHub Pages

GitHub Pages 目前由 GitHub Pages 內建的 pages build and deployment 流程隨 main 更新發布；最新提交 00ba2ff955c469337fe4661eb8f62e3692ee0e36 已由該流程成功完成。專案的 .github/workflows/deploy-pages.yml 保留為手動 workflow_dispatch 備援，避免與 Pages 內建部署同時執行而競爭部署鎖。若更改 Pages 的 Build and deployment 來源，必須同步調整部署流程，確保同一時間只有一條自動部署路徑。

預期網站網址：
https://edward11031709.github.io/Food_map/

會員註冊使用 Email／密碼，若啟用郵件驗證，需完成收件匣確認。若確認信導回失敗，請在 Supabase Authentication → URL Configuration 將上述 Pages 網址加入 Redirect URLs。最新 GitHub Pages 部署狀態仍須以 Actions workflow 成功紀錄為準。

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

# 資料字典

> 本文件描述黑貓飲食指南 MVP 的 Supabase schema。實際欄位以已套用的 migration 為準。

## places（店家主檔）

| 欄位 | 型別 | 用途 |
|---|---|---|
| id | uuid | 穩定識別碼 |
| slug / name | text | 網站識別字串與店名 |
| aliases | text[] | 店名別名及搜尋關鍵字 |
| description | text | 可查證的中性簡介 |
| business_type / cuisines / meal_times / dietary_options | text[] | 多維分類與飲食標籤 |
| address / city / district / postal_code | text | 標準化地址 |
| latitude / longitude | double precision | WGS84 座標，必須成對提供 |
| coordinate_source / coordinate_verified_at | text / timestamptz | 座標來源及查證時間 |
| phone / website_url / social_urls | text / jsonb | 官方聯絡資訊 |
| price_min / price_max / currency | integer / integer / text | TWD 消費參考範圍 |
| dining_time_policy | text | limited / unlimited / unknown / not_applicable |
| dining_time_limit_minutes | integer | 用餐限制分鐘數 |
| services / amenities | text[] | 服務及設施 |
| verification_status | text | unverified / partially_verified / verified / needs_review / closed / unknown |
| is_published | boolean | 是否能被公開網站讀取 |
| last_verified_at | timestamptz | 最近查證時間 |

## place_hours（營業時間）

day_of_week 使用 0=週日至 6=週六。一天多個營業時段可建立多列；跨午夜時段的 closes_at 可早於 opens_at。特殊日期可利用 valid_from、valid_until 與 notes 表達。

## menu_items（菜單品項）

品項包含名稱、描述、分類、TWD 價格、供應餐期、飲食標籤、供應狀態、來源及最近查證時間。未知價格必須保留 null。

## sources / place_sources（來源追蹤）

sources 保存公開來源名稱、網址、來源類型、授權資訊與擷取／查證時間。place_sources 記錄店家與來源關聯、該來源支持的欄位及可信度。來源衝突不得直接刪除，需標記待確認。

## ingestion_runs（蒐集任務日誌）

內部記錄查詢條件、地區、執行狀態、新增／更新／略過數量與錯誤摘要。此表不向匿名前端開放。

## Enum 與值域

- dining_time_policy: limited, unlimited, unknown, not_applicable
- verification_status: unverified, partially_verified, verified, needs_review, closed, unknown
- day_of_week: 0–6（週日到週六）
- 幣別固定為 TWD
- 未查證資訊不得設為 verified 或發布。


## mrt_stations（捷運車站主檔）

| 欄位 | 型別 | 用途 |
|---|---|---|
| station_code | text | 官方車站代碼，唯一 |
| station_name / station_name_en | text | 中英文站名 |
| line_ids | text[] | 所屬路線代碼 |
| operator / city / district | text | 營運單位及行政區 |
| latitude / longitude | double precision | 車站座標，必須成對提供；未確認時為 null |
| station_source_url | text | 官方站點／路網來源 |
| target_place_count | integer | 每站候選店家目標數，預設 100 |
| is_active | boolean | 是否列入目前站點覆蓋範圍 |
| last_verified_at | timestamptz | 最近一次查證車站資料時間 |

## place_mrt_stations（店家—捷運站關聯）

- 一家店只在 `places` 建立一筆，可關聯多個捷運站。
- `straight_line_distance_m` 為直線距離；`walking_distance_m` 與 `walking_minutes` 只有在取得可追溯步行路線後才填入。
- `assignment_method`: `official_source`、`verified_walking_route`、`straight_line`、`manual`、`needs_review`。
- `verification_status`: `verified`、`partially_verified`、`needs_review`、`unverified`。
- `source_url` 與 `last_verified_at` 記錄此關聯的依據及查證時間。

`is_published=true` 代表候選資料可以在網站公開顯示，不等於資料已驗證；請依 verification_status 顯示「部分查證／待確認」。Google Maps 搜尋 URL 是導航與人工核對入口，不得作為精確座標或營業狀態的證據。

# 捷運站周邊店家覆蓋規劃

## 目標與範圍

- 目標：每個營運中的大台北捷運站建立 100 家附近店家的候選關聯。
- 站點清單採臺北市政府交通局公布的全網絡版本，包含六條路線及環狀線一期。交通局 2026-09-19 更新的官方 FAQ 列出全網絡 **132 站**，且於 2026-11-09 複核：[交通局官方說明](https://english.dorts.gov.taipei/News_Content.aspx?n=AB4A7B7BEC662D44&s=CC75FA615F8BE89C&sms=5B794C46F3CDE718)。本專案以 132 站作規劃基準，若官方日後更新，需重新核對。
- 臺北市資料大平臺的「臺北捷運車站資料服務」CSV 由捷運公司提供，2026-09-04 更新，含 StationID、StationName、StationPosition、StationAddress 等欄位：[官方車站資料集](https://data.taipei/dataset/detail?id=1eefa68d-7c8d-491b-8e75-66a161947426)。
- 同平台「臺北捷運路線車站資料服務」CSV 亦於 2026-09-04 更新，含 LineID 及 Stations 等欄位，可用於補齊路線關係：[官方路線車站資料集](https://data.taipei/dataset/detail?id=8bf00fa8-86a5-437e-b5c7-9bc0fe0e2971)。
- 臺北市政府的「設址臺北市所營事業含餐館業清冊」CSV 更新於 2026-07-30，包含統一編號、商業名稱、地址及經緯度；提供機關提醒登記 F501060 不代表現場確實營業，必須另行查證：[資料集](https://data.taipei/dataset/detail?id=178abc4e-fe32-4fc9-af3a-7baf1c15082c)。
- 初始附近範圍：車站周邊 800 公尺。若候選不足 100 家，擴大範圍前需記錄實際半徑及原因；不以重複店家或無來源紀錄填滿。
- 100 是每站店家關聯目標，不是每站都新建 100 份不同店家主檔。同一家店可同時關聯多站，`places` 只保留一份。

## 資料表

- `mrt_stations`: 官方車站代碼、站名、路線、行政區、座標、來源、啟用狀態與 `target_place_count=100`。
- `place_mrt_stations`: 店家與站點多對多關聯，分開保存直線距離、步行距離、步行分鐘數、關聯方式和查證狀態。
- `places`: 店家主檔；`sources` / `place_sources`: 各欄位來源與關聯。

## 查證標準

| 狀態 | 意義 | 使用方式 |
|---|---|---|
| `verified` | 店名、分店地址、目前營運狀態及必要店家資訊已完成交叉查證 | 官方現行資料與可接受的第二來源互相吻合 |
| `partially_verified` | 至少有可靠來源能確認店名／分店位置，但營業狀態、時段或其他資料仍未完整核實 | 官方商場名錄或官方交通／商場資料能識別店名與樓層 |
| `needs_review` | 只有第三方搜尋結果、來源不一致、可能歇業或分店資訊不完整 | 留給人工核對，不可當成已確認 |
| `unverified` | 尚未取得足夠來源 | 不可標成 verified |

**重要：** 政府商業登記只證明資料登記存在，不直接證明現場仍營業。臺北市「設址臺北市所營事業含餐館業清冊」的提供機關備註亦明確指出，登記餐館業項目是否實際營業須以現場為準。不得為達成每站 100 家的數量而把未確認店家改標為已查證。

## 來源優先順序

1. 臺北市政府／新北市政府開放資料、捷運公司站點資料及官方商場名錄。
2. 店家官方網站、官方 LINE／社群及店家現行分店頁。
3. Google Maps 店家頁、地圖搜尋結果，可用於導航與交叉查證。
4. Michelin Guide、可信餐飲名錄等第三方資料，用於補充，不可取代官方營業資訊。

網站詳情頁會提供 Google Maps 搜尋連結（店名＋地址），並在已知時提供官方網站。Google Maps 搜尋 URL 是方便使用者定位與人工核對的入口，不代表資料已驗證或提供精確座標。

## 第一批進度（2026-11-16）

| 車站 | 店家關聯數 | 目標 | 狀態 |
|---|---:|---:|---|
| 台北101／世貿站（R03） | 58 | 100 | 進行中 |

目前 58 家：52 家部分查證、6 家待確認、0 家完全查證。前 52 家來自台北101官方店家／美食名錄，僅將可由官方名錄支持的店名與樓層列為部分查證；另 6 家來自信義商圈 Google Maps 候選搜尋，來源能提供店名與地址，但是否落在 800 公尺搜尋半徑及目前營業狀態仍待確認，故標為 needs_review。所有店家未核實的營業時段、價格及精確座標留空；沒有座標的店家不會出現在地圖 marker 上。

目前資料庫只建立台北101／世貿站（R03）這 1 個站點主檔；其餘 131 站尚待依官方最新站碼清單匯入。132 站 × 每站 100 家是約 13,200 筆站點—店家關聯目標，不代表要建立 13,200 家互不重複的店家。


## 第二批擴充（2026-11-17）

| 車站 | 店家關聯數 | 目標 | 本輪新增 | 查證摘要 |
|---|---:|---:|---:|---|
| 台北101／世貿站（R03） | 79 | 100 | 21 | 58 家部分查證、21 家待確認、0 家完全查證 |

本輪新增 21 筆店家主檔及 21 筆 R03 關聯，並新增 29 筆店家—來源關聯。4 家來自台北101官方近期美食專題：Läderach 台北101旗艦店、饗壹鍋台北101店、養心茶樓 mini 台北101店、五燈獎豬腳飯台北101店。另補充 17 間信義區早餐、便當、乾麵、牛肉麵、豆漿、水煎包、麵線、豆花及甜點候選：家香豆漿店、詹字號麵食館、開囍滷肉專賣店、藤香厚工豆花、加油添醋烏醋乾麵、黃金麵線、徐記古早味水煎包、潮饌麵府、上悅龍記燒臘、包果 Baoguo、老北一菜盒店、Jane味碳烤三明治、阿珍大腸麵線、古早味雞蛋糕、穆記牛肉麵、七飯 SEVEN RICE、宜品乾拌麵。

本輪新增 21 筆中，6 筆列為 partially_verified（4 筆官方商場名錄，另含米其林指南支持的開囍與商家名錄／外送頁支持的上悅龍記）；15 筆列為 needs_review，因為來源多為地圖候選或第三方目錄，仍需現場／官方核對營業狀態與細節。店家主檔新增數 21，疑似重複略過數 0；既有 Master Jun Beef Noodles 台北101店沒有重複建立，而是補入「竣師傅」別名及官方新進品牌來源。

**半徑限制：** 17 間街邊店是信義區／吳興街、莊敬路一帶候選名單；目前尚未全部完成距離量測及步行路徑核查，因此關聯的直線距離、步行距離與步行分鐘數均保留 null，且關聯狀態為 needs_review。不能將所有店家宣稱為已確認位於 R03 站 800 公尺內。官方商場店家則以台北101名錄作為館內位置依據。

本輪未填入未核實的價格、營業時段、菜單售價或精確座標。新增店家若 last_verified_at 為 null，網站顯示「尚無確認紀錄」；只有當本輪來源支持明確欄位時才填入日期，不會把資料輸入日期當成完整營業查證日期。

主要來源：
- [台北101官方新進美食專題](https://stage.taipei101mall.com.tw/article/1150)
- [Läderach Taiwan 官方網站／門市資訊](https://tw.laderach.com/)
- [米其林指南：開囍](https://guide.michelin.com/tw/zh_TW/taipei-region/taipei/restaurant/open-smile)
- [上悅龍記燒臘商家名錄](https://bizlion.com.tw/bizlion/Store/Detail?storeId=9296) 及 [Uber Eats 店家頁](https://www.ubereats.com/tw/store/%E4%B8%8A%E6%82%85%E9%BE%8D%E8%A8%98%E7%87%92%E8%87%98-%E5%8F%B0%E5%8C%97%E4%B8%96%E8%B2%BF%E5%BA%97/CxtTUpGdSn-x_acqi5D_oQ)
- [iFoodie 世貿101小吃名單](https://ifoodie.tw/explore/%E5%8F%B0%E5%8C%97%E5%B8%82/list/%E4%B8%96%E8%B2%BF101%E5%B0%8F%E5%90%83)
- 其餘街邊候選均在 Supabase sources 留存各店的 Google Maps 搜尋連結，僅作候選定位與人工核對入口，不視為精確座標或營業狀態證明。

截至本輪結束，R03 尚有 21 筆關聯未達 100 家目標；但是否符合 800 公尺範圍與資料查證品質仍須另行核對，不能僅按筆數視為完成。


## 第三批補查與擴充（2026-11-17）

| 車站 | 店家關聯數 | 目標 | 本輪新增 | 重新查核 | 本輪狀態 |
|---|---:|---:|---:|---:|---|
| 台北101／世貿站（R03） | 80 | 100 | 1 | 3 | 61 家部分查證、19 家待確認、0 家完全查證 |

本輪新增 1 家「秦小姐豆漿 信義店」，建立 1 筆 places 主檔、1 筆 R03 關聯及 2 筆來源關聯。地址與電話由 Uber Eats 店家頁及 WANT EAT FOOD 2026-08-23 資料交叉支持；列為 partially_verified，因目前仍未取得店家官方現行營業公告，營業時間與價格保留未知。R03 關聯維持 needs_review，未量測可追溯距離，不能宣稱符合 800 公尺範圍。

重新查核 3 家既有店家：家香豆漿店（OpenRice 當日可讀資料及 2026-04-07 更新文章）、藤香厚工豆花（臺北市友善店家資料及臺北市商業處資料）、開囍滷肉專賣店（米其林指南及 2026-10-01 近期店家資料）。本輪只更新查核日期及來源關聯，不把第三方舊菜單或價格當成現行價格，也未批次覆寫營業時間。

藤香厚工豆花的臺北市友善店家資料明確列出地址、電話、營業時間、Facebook 連結及座標（25.0334168, 121.5590325），並有臺北市商業處資料交叉支持品牌與地址；因此補入可追溯座標及座標來源，地圖可依此建立 marker。此座標不是推測或由商場地址轉換而來。

另查到「早點，見面」的愛食記搜尋結果有已歇業版本，與仍顯示營業的舊索引頁存在衝突，因此本輪**沒有新增**該店，保留人工確認，不把舊名錄當成仍營業證據。

本輪新增數 1、重複略過數 0、重新查核數 3、店家重要資訊有變動數 1（藤香厚工豆花補入有來源的座標與官方社群連結）、待人工確認數 1（秦小姐豆漿的 R03 距離／營業狀態仍待確認；既有 needs_review 紀錄亦持續保留）。R03 目前 80/100，尚差 20 筆關聯；其中部分關聯距離尚未確認，不能以筆數代表 800 公尺範圍已完成。

主要來源：
- [臺北市友善店家：藤香厚工豆花](https://friendlystore.taipei/store/tw/pg1/3/company/7467)
- [臺北市商業處：藤香厚工豆花](https://www.tcooc.gov.taipei/cp.aspx?n=8D0974959002A45D&s=D9B4B5182196CDA3)
- [OpenRice：家香豆漿店](https://tw.openrice.com/zh/taipei/r-%E5%AE%B6%E9%A6%99%E8%B1%86%E6%BC%BF%E5%BA%97-%E4%BF%A1%E7%BE%A9%E5%8D%80-%E5%8F%B0%E7%81%A3%E8%8F%9C-%E6%B2%99%E5%BE%8B-r525743)
- [Achu：家香豆漿店（2026-04-07）](https://achu.tw/jia-xiang-wuxing/)
- [米其林指南：開囍](https://guide.michelin.com/tw/zh_TW/taipei-region/taipei/restaurant/open-smile)
- [WANT EAT FOOD：秦小眷豆漿信義店（2026-08-23）](https://wanteatfood.com/98736)
- [Uber Eats：秦小姐豆漿信義店](https://www.ubereats.com/tw/store/%E7%A7%A6%E5%B0%8F%E5%A7%90%E8%B1%86%E6%BC%BF-%E4%BF%A1%E7%BE%A9%E5%BA%97/0ottRnXpXC-M-jcTZLpWeQ)
- [愛食記：早點，見面（資料頁出現已歇業版本）](https://www.ifoodie.tw/restaurant/65f6e9c57be9c325e9c257d0-%E6%97%A9%E9%BB%9E-%E8%A6%8B%E9%9D%A2-%E6%97%A9%E9%A4%90%E5%BA%97-%E5%B7%B2%E6%AD%87%E6%A5%AD-)

last_verified_at 僅對本輪實際重新核對的既有店家更新；新增店家日期表示本輪來源查核日期，不代表完整營業狀態已確認。網站卡片與詳情仍直接使用 last_verified_at；null 仍顯示「尚無確認紀錄」。本輪未新增 migration，未修改 schema 或 RLS。


## 第四批每週維護（2026-11-23）

| 車站 | 候選關聯數 | 目標 | 本輪新增 | 重新查核 | 店家主檔狀態 | 關聯狀態 |
|---|---:|---:|---:|---:|---|---|
| 台北101／世貿站（R03） | 83 | 100 | 3 | 4 | 68 部分查證、15 待確認 | 56 部分查證、27 待確認、0 完全查證 |

本輪新增 3 家，均先比對既有名稱、別名及地址，未發現重複：
- **陳記米糕**：臺北市信義區吳興街150號，02-2737-3426。以 Uber Eats、WANT EAT FOOD（2026-03-15）及 WalkerLand（2026-02-25）交叉支持店名、地址、電話及品項，列為 partially_verified。
- **查記麵館**：臺北市信義區吳興街37號1樓，02-2758-8538。以 FindGlocal 店家資訊、WalkerLand（2026-04-09）及 PEKO（2025-12-19）交叉支持店名、地址、電話及麵食資訊，列為 partially_verified。
- **世貿好吃炸蛋餅**：臺北市信義區吳興街106巷11號，0936-723-238。以愛食記（含 2026-11-01 食記）及 WalkerLand（2026-04-09）支持店名、地址、電話及早餐類型，列為 partially_verified。

以上三家均未寫入價格、營業時間、精確座標或未經證實的飲食需求。來源提及的菜單與營業時間可能變動，未將舊文章數字當成目前值。

重新查核 4 家既有店家：
- **七飯 SEVEN RICE 世貿店**：重新核對分店地址、電話及近期店家公告，補入頁面所連結的 LINE 聯絡入口；狀態由 needs_review 調整為 partially_verified。
- **徐記古早味水煎包－吳興店**：重新核對 Uber Eats 現行店家頁、地址及近期評價；狀態調整為 partially_verified。電話仍為 null。
- **加油添醋烏醋乾麵**：以 2026-06-25 店家介紹及 Uber Eats 頁核對名稱、地址、電話與品項；狀態調整為 partially_verified。但來源明確描述從 R03 步行約 15 分鐘，因此其 R03 關聯仍標 needs_review，不視為 800 公尺內已確認店家。
- **黃金麵線（吳興街）**：以 TVBS 食尚玩家店家頁及 Uber Eats 頁核對名稱、地址、電話。不同來源的營業時段略有差異，故不更新營業時間；狀態調整為 partially_verified。

**距離與 800 公尺限制：** 本輪沒有新增任何座標，也沒有寫入直線距離或步行距離。WANT EAT FOOD 對陳記米糕刊載「500 公尺／步行 7 分鐘」，PEKO 對查記麵館刊載步行約 5 分鐘；這些是第三方文字敘述，並非可追溯的實際路徑或官方測量，因此只保留來源，不將數字寫入距離欄位，兩家 R03 關聯均維持 needs_review。世貿好吃炸蛋餅也尚無可追溯距離，關聯維持 needs_review。另有來源指出邱記涼麵距 R03 約 850 公尺／步行 12 分鐘，超過初始 800 公尺範圍，本輪不新增其 R03 關聯；281 雞蛋糕亦因無法確認在 800 公尺範圍內而未新增。

截至本輪結束，R03 有 83 筆候選店家關聯，尚差 17 筆達到名目 100 家目標；但**0 筆關聯具有可追溯的直線或步行距離，0 筆可據此宣稱已完成 800 公尺範圍查證**。R03 車站主檔的 latitude／longitude 仍為 null；資料庫目前只有 R03 一筆車站主檔，依官方文件規劃的其餘 131 站尚未匯入。不可把 83 筆候選關聯當成 83 家都在 800 公尺內。

本輪統計：新增 3、重複略過 0、重新查核 4、既有店家重要聯絡資訊變動 1（七飯補入 LINE 入口）、查證狀態更新 4、待人工確認 27 筆站點關聯及 15 家店家主檔。另有 9 家已發布店家的 last_verified_at 仍為 null，網站應顯示「尚無確認紀錄」。

最後確認日期呈現已檢查：index.html 卡片及詳情直接使用 places.last_verified_at，null 顯示「尚無確認紀錄」；查證狀態以 verification_status 顯示；日期以 Asia/Taipei 格式化。沒有以 created_at／updated_at 代替查證日期。本輪沒有修改 index.html，因此沒有宣稱完成新的前端互動測試。

主要來源：
- [陳記米糕－Uber Eats](https://www.ubereats.com/tw/store/%E9%99%B3%E8%A8%98%E7%B1%B3%E7%B3%95/GKXlwR6eTYexXxIF9zB2xw)
- [陳記米糕－WANT EAT FOOD（2026-03-15）](https://wanteatfood.com/18838)
- [陳記米糕－WalkerLand（2026-02-25）](https://www.walkerland.com.tw/article/view/421965)
- [查記麵館－FindGlocal 店家資訊](https://www.findglocal.com/TW/Taipei/348780175564083/%E6%9F%A5%E8%A8%98%E9%BA%B5%E9%A4%A8%E7%B2%89%E7%B5%B2%E5%9C%98)
- [查記麵館－PEKO（2025-12-19）](https://pekoblog.tw/chachi/)
- [世貿好吃炸蛋餅－愛食記](https://www.ifoodie.tw/restaurant/6ae73bfe88a06b1c26416db6-%E4%B8%96%E8%B2%BF%E5%A5%BD%E5%90%83%E7%82%B8%E8%9B%8B%E9%A4%85)
- [吳興街銅板美食－WalkerLand（2026-04-09）](https://www.walkerland.com.tw/subject/view/422682)
- [徐記古早味水煎包－Uber Eats](https://www.ubereats.com/tw/store/%E5%BE%90%E8%A8%98-%E5%8F%A4%E6%97%A9%E5%91%B3%E6%B0%B4%E7%85%8E%E5%8C%85-%E5%90%B3%E8%88%88%E5%BA%97/Sz_DA08iVpWtTUrtgPsKow)
- [七飯 SEVEN RICE－FoodYas 店家資訊與公告](https://www.foodyas.com/TW/Taipei/103276025726483/%E4%B8%83%E9%A3%AF--SEVEN-RICE---%E5%A5%BD%E5%90%83%E5%81%A5%E5%BA%B7%E9%A4%90%E7%9B%92)
- [加油添醋－2026-06-25 店家介紹](https://litwenblog.com/jiayoutiancu/)
- [加油添醋－Uber Eats](https://www.ubereats.com/tw/store/%E5%8A%A0%E6%B2%B9%E6%B7%BB%E9%86%8B%E9%BA%B5%E5%BA%97/lMJvHpXgSBGtSES30YEqFg)
- [黃金麵線－TVBS 食尚玩家](https://supertaste.tvbs.com.tw/infocard/26937)
- [黃金麵線－Uber Eats](https://www.ubereats.com/tw/store/%E4%BF%A1%E7%BE%A9%E9%BB%83%E9%87%91%E9%BA%B5%E7%B7%9A-%E5%90%B3%E8%88%88%E8%A1%97/RWWGSAEaQuSe3LyapW2AaA)
- [邱記涼麵－WANT EAT FOOD（2026-06-18；刊載 850 公尺）](https://wanteatfood.com/28271)

本輪未新增 migration、未修改 schema 或 RLS。資料表 RLS 仍全部啟用；公開角色無店家／來源／捷運資料寫入權限，authenticated 的 INSERT／DELETE 僅限本人 favorites 與 place_visits。Supabase 遠端 migration history 與 Repo 內 6 筆 migration 版本一致。

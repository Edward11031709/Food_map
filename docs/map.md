# 地圖與座標規範

## MVP 技術

- Leaflet 1.9.4 負責互動地圖。
- 預設使用 OpenStreetMap standard raster tiles。
- 地圖初始化中心為台北市；這只是初始視角，不代表只有台北有資料。
- 只對已發布且具有有效 WGS84 經緯度的店家建立 marker。
- Marker 綁定店家穩定 ID；清單篩選和地圖 marker 使用相同的資料集合。
- Marker 點擊可開啟店家詳情；詳情可連到 OSM 的店家位置或地址搜尋。

## 座標規則

- latitude 必須在 -90 至 90，longitude 必須在 -180 至 180，且兩者必須同時為 null 或同時有值。
- 必須記錄 coordinate_source 和 coordinate_verified_at。
- 不得只憑店名或模糊地址猜座標。
- MVP 不使用公共 Nominatim 做前端 autocomplete 或批次 geocoding；無座標店家仍可透過地址連結開啟 OSM 搜尋。

## OSM 使用規則

- 明確顯示 © OpenStreetMap contributors，連結至 https://www.openstreetmap.org/copyright。
- 使用標準圖磚時遵守現行 Tile Usage Policy，保留正常快取及 Referer；禁止大量預抓、批次下載與離線圖磚服務。
- OSM 資料依 ODbL 授權，使用或再散布資料前確認署名及相同方式分享義務。
- 若流量或用途不符合公共 tile 服務政策，改用適合的 OSM 圖磚供應商或自架服務；底圖 URL 應可設定切換。
- 每次重大地圖功能變更前重新檢查 OSM 官方政策。


## 星空主題搭配白色簡約地圖

- 維持 Leaflet + OpenStreetMap standard raster tiles；白色地圖直接使用原始標準圖磚，不套用灰階反相濾鏡。
- 地圖外框、縮放控制、署名區及 popup 使用白色／淺灰面板，文字採深海軍藍與石墨灰；香檳金只用於細節與互動強調。
- 店家 Marker 使用香檳金星點作為預設圖示，各店家類型可以套用低飽和分類色；marker 點擊仍可開啟店家詳情。
- 店家詳情頁提供 Google 地圖搜尋連結；已查證且有官網的店家同時顯示官方網站。Google Maps URL 以店名及可用地址組成搜尋連結，不應當作精確座標證據。
- 地圖 attribution 必須保持清晰可見並連結至版權頁。

# TestFlight 部署指南

## 目前狀態

- ✅ Bundle ID: `com.almightyken0425.susugigiapp`
- ✅ Version: 1.0
- ✅ Build: 1
- ✅ In-App Purchase Capability 已啟用
- ✅ 訂閱產品已在 App Store Connect 建立

---

## 📋 TestFlight 部署步驟

### 步驟一：在 Xcode 中建立 Archive

1. **確保選擇正確的 Scheme**
   - 在 Xcode 頂部工具列
   - 確認選擇 `SuSuGiGiApp` scheme
   - 裝置選擇 **Any iOS Device (arm64)**

2. **建立 Archive**
   - 選單：**Product** → **Archive**
   - 等待編譯完成（可能需要 5-10 分鐘）
   - 編譯成功後會自動開啟 **Organizer** 視窗

### 步驟二：上傳到 App Store Connect

1. **在 Organizer 中**
   - 選擇剛才建立的 Archive
   - 點擊右側的 **Distribute App** 按鈕

2. **選擇發布方式**
   - 選擇 **App Store Connect**
   - 點擊 **Next**

3. **選擇發布選項**
   - 選擇 **Upload**
   - 點擊 **Next**

4. **Distribution Options**
   - ✅ **Upload your app's symbols** - 建議勾選（用於 crash 分析）
   - ✅ **Manage Version and Build Number** - 建議勾選（自動管理版本號）
   - 點擊 **Next**

5. **Signing**
   - 選擇 **Automatically manage signing**
   - 點擊 **Next**

6. **Review**
   - 檢查資訊
   - 點擊 **Upload**

7. **等待上傳完成**
   - 上傳時間取決於網路速度（通常 5-15 分鐘）
   - 上傳完成後會顯示成功訊息

### 步驟三：等待處理

1. **前往 App Store Connect**
   - 網址: https://appstoreconnect.apple.com/
   - 選擇您的 App **$wish**

2. **檢查 Build 狀態**
   - 點擊 **TestFlight** 標籤
   - 在 **Builds** 區域
   - **重要：處理 Missing Compliance**
     - 若看到黃色驚嘆號 **Missing Compliance**
     - 點擊該文字或旁邊的 **Manage** 按鈕
     - 選擇 **No** (若您的 App 只使用標準 HTTPS 或無特殊加密)
     - 或選擇 **Yes** -> **Yes** (符合免責條款)
     - 點擊 **Start Internal Testing**
   - 等待狀態變為 **Ready to Test**
![alt text](image.png)

### 步驟四：設定 Internal Testing

1. **建立測試群組**
   - 在 TestFlight 頁面
   - 左側選單選擇 **Internal Testing**
   - 點擊 **+** 建立新群組
   - **Group Name**: `Internal Testers`

2. **新增測試人員**
   - 點擊 **Add Testers**
   - 選擇您自己的 Apple ID（必須在 App Store Connect 的 Users and Access 中）
   - 點擊 **Add**

3. **選擇 Build**
   - 在群組中點擊 **Add Build**
   - 選擇剛才上傳的 Build (1.0 - 1)
   - 點擊 **Add**

### 步驟五：在裝置上安裝 TestFlight

1. **安裝 TestFlight App**
   - 在 iPhone 上開啟 App Store
   - 搜尋 **TestFlight**
   - 下載並安裝（Apple 官方 App）

2. **接受邀請**
   - 檢查您的 Email
   - 點擊 TestFlight 邀請連結
   - 或在 TestFlight App 中查看可用的 App

3. **安裝 App**
   - 在 TestFlight 中點擊 **$wish**
   - 點擊 **Install**
   - 等待安裝完成

### 步驟六：測試 IAP

1. **設定 Sandbox 帳號**
   - 在 iPhone 上：**設定** → **App Store**
   - 向下捲動到 **SANDBOX ACCOUNT**
   - 登入您在 App Store Connect 建立的 Sandbox 測試帳號

2. **測試購買流程**
   - 開啟 $wish App
   - 導航到 **Settings** → **Upgrade to Premium**
   - 確認可以看到兩個訂閱選項：
     - Level 1 Premium Monthly - USD 0.99
     - Level 1 Premium Yearly - USD 9.99
   - 點擊訂閱按鈕
   - 完成購買（不會實際扣款）
   - 確認 Premium 狀態更新

3. **測試 Restore Purchases**
   - 點擊 **恢復購買** 按鈕
   - 確認可以恢復之前的購買

---

## ⚠️ 常見問題

### Q1: Archive 按鈕是灰色的？
**A**: 確保選擇了 **Any iOS Device (arm64)**，而不是模擬器

### Q2: 上傳失敗，提示 Bundle ID 不符？
**A**: 確認 Xcode 中的 Bundle ID 與 App Store Connect 中的 App 一致

### Q3: Build 一直顯示 Processing (超過 1 小時)？
**A**: 這通常是伺服器卡住，請直接**上傳一個新 Build** 來解決：
1. **修改 Build Number**:
   - 在 Xcode 左側點擊藍色專案圖示 (`SuSuGiGiApp`)
   - 選擇 **Targets** > **SuSuGiGiApp**
   - 點擊 **General** 分頁 > **Identity** 區塊
   - 將 **Build** 從 `1` 改為 `2` (Version `1.0` 不動)
2. **重新上傳**:
   - 選單 **Product** > **Archive**
   - 完成後點擊 **Distribute App** 再次上傳
   - 新的 Build 2 通常會順利通過處理

### Q4: 無法載入產品列表？
**A**: 
- 確認已在 Settings → App Store → Sandbox Account 登入測試帳號
- 確認 Product ID 與程式碼中的完全一致
- 確認訂閱產品狀態為 "Ready to Submit" 或 "Approved"

### Q5: 購買後狀態沒有更新？
**A**: 
- 檢查 `PremiumContext.tsx` 中的邏輯
- 查看 Xcode console log 是否有錯誤訊息
- 確認 `iapService` 正確處理購買事件

---

## 📝 測試檢查清單

### Archive 前
- [ ] 確認 Bundle ID 正確
- [ ] 確認 Version 和 Build 號碼
- [ ] 確認 In-App Purchase Capability 已啟用
- [ ] 確認程式碼中的 Product ID 正確

### 上傳後
- [ ] Build 狀態變為 "Ready to Test"
- [ ] Internal Testing 群組已建立
- [ ] 測試人員已新增
- [ ] Build 已加入測試群組

### 測試時
- [ ] TestFlight App 已安裝
- [ ] Sandbox 帳號已登入
- [ ] App 成功安裝
- [ ] 可以載入產品列表
- [ ] 可以完成購買
- [ ] Premium 狀態正確更新
- [ ] Restore Purchases 功能正常

---

## 🎯 下一步

完成 Internal Testing 後，如果需要更廣泛的測試：

### External Testing
1. 在 TestFlight 中選擇 **External Testing**
2. 建立新的測試群組
3. 新增 Build
4. 提交審核（通常 1-2 天）
5. 審核通過後，可以邀請最多 10,000 個外部測試人員

---

## 📞 需要協助？

如果在任何步驟遇到問題：
1. 檢查 Xcode 的錯誤訊息
2. 查看 App Store Connect 的 Email 通知
3. 參考 Apple 官方文件：https://developer.apple.com/testflight/

**文件結束**

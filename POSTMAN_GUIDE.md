# 📮 POSTMAN SETUP & USAGE GUIDE

## 🚀 **NHANH GỌN: 5 PHÚT CÓ THỂ TEST**

---

## 📥 **IMPORT COLLECTION**

### **Bước 1: Mở Postman**
```bash
# Download Postman từ: https://www.postman.com/downloads/
```

### **Bước 2: Import Collection**
```
File → Import → Upload Files → Chọn "BidChain_API_Collection.postman_collection.json"
```

### **Bước 3: Setup Environment**
```
1. Click "Environments" (bên trái)
2. Click "+" để tạo environment mới
3. Đặt tên: "BidChain Local"
4. Thêm variables:
   - base_url: http://localhost:3000/api
   - jwt_token: (để trống)
   - admin_token: (để trống)
   - user_id: (để trống)
   - auction_id: (để trống)
   - deposit_request_id: (để trống)
```

---

## 🎯 **TEST WORKFLOW HOÀN CHỈNH**

### **PHASE 1: SETUP & AUTHENTICATION**

#### **1. Register User**
```
Collection: 1. Authentication → Register User
Method: POST
Body: {
  "username": "testuser",
  "password": "123456"
}
✅ Click Send → Token tự động lưu vào environment
```

#### **2. Fund Wallets (Demo)**
```
Collection: 1. Authentication → Demo: Fund All Users
Headers: Authorization: Bearer {{jwt_token}}
✅ Click Send → Nhận 10 ETH cho mỗi user
```

#### **3. Check Balance**
```
Collection: 2. Auction System → Get Wallet Balance
Headers: Authorization: Bearer {{jwt_token}}
✅ Click Send → Xem số dư VND & ETH
```

### **PHASE 2: AUCTION SYSTEM**

#### **1. Create Auction**
```
Collection: 2. Auction System → Create Auction
Headers: Authorization: Bearer {{jwt_token}}
Body: {
  "startingPriceWei": "200000000000000000000",  // 10M VND = 0.2 ETH
  "stepPriceWei": "10000000000000000000",       // 500k VND = 0.01 ETH
  "durationSeconds": 1800,                       // 30 phút
  "metadataUrl": "ipfs://test-metadata"
}
✅ Click Send → auction_id tự động lưu
```

#### **2. Deposit to Contract**
```
Collection: 2. Auction System → Deposit VND to Contract
Headers: Authorization: Bearer {{jwt_token}}
Body: {
  "amount_vnd": 1000000,  // 1M VND = 0.02 ETH
  "momo_ref_id": "MM123456"
}
✅ Click Send → ETH transfer vào contract
```

#### **3. Place Bid**
```
Collection: 2. Auction System → Place Bid
Headers: Authorization: Bearer {{jwt_token}}
Body: {
  "auction_id": "{{auction_id}}",
  "amount_vnd": 12500000,  // 12.5M VND
  "signature": "0x_mock_signature_for_demo",
  "nonce": 1
}
✅ Click Send → Bid thành công
```

### **PHASE 3: MOMO PAYMENT SYSTEM**

#### **1. Create Deposit Request**
```
Collection: 3. Momo Payment → Create Deposit Request
Headers: Authorization: Bearer {{jwt_token}}
Body: {
  "amount_vnd": 1000000
}
✅ Click Send → Nhận QR code Momo
```

#### **2. Simulate Momo Payment**
```
Collection: 3. Momo Payment → Simulate Momo Callback
Body: (đã có sẵn callback data mẫu)
✅ Click Send → Payment status: PAID
```

#### **3. Admin Approve**
```
Collection: 3. Momo Payment → Admin Approve Deposit
Headers: Authorization: Bearer {{admin_token}}
URL: .../{{deposit_request_id}}
✅ Click Send → ETH transfer to user wallet
```

---

## 🔧 **ADVANCED TESTING FEATURES**

### **Automated Token Management**
```javascript
// Scripts tự động lưu token:
pm.test("Save token", function () {
    const token = pm.response.json().token;
    if (token) {
        pm.environment.set("jwt_token", token);
    }
});
```

### **Response Validation**
```javascript
// Test response structure:
pm.test("Balance structure", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('balance_vnd');
    pm.expect(jsonData).to.have.property('formatted_balance');
    pm.expect(jsonData.formatted_balance).to.include('đ');
});
```

### **Error Testing**
```javascript
// Test error responses:
pm.test("Authentication required", function () {
    pm.response.to.have.status(401);
});
```

---

## 📊 **TEST SCENARIOS**

### **✅ Happy Path (15 requests)**
1. ✅ Register → Login → Fund → Balance
2. ✅ Create Auction → Get Auctions → Deposit
3. ✅ Place Bid → Check Auction → Transactions
4. ✅ Create Deposit Request → Momo Callback → Admin Approve

### **❌ Error Cases**
```
401 Unauthorized: Missing/invalid JWT
400 Bad Request: Invalid amount, wrong auction
409 Conflict: Concurrent bid race condition
500 Server Error: Blockchain connection issues
```

### **🔄 Flow Testing**
```
Runner → Collection Runner → Select "BidChain API"
Iterations: 10
Delay: 1000ms
→ Test concurrent requests
```

---

## 📈 **PERFORMANCE METRICS**

### **Expected Results:**
```
✅ Response Time: < 500ms
✅ Success Rate: > 99%
✅ Blockchain Confirmations: < 30s
✅ Concurrent Users: 100+
```

### **Monitor Performance:**
```javascript
// Add to Tests tab:
pm.test("Response time < 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

pm.test("Status is 200", function () {
    pm.response.to.have.status(200);
});
```

---

## 🐛 **TROUBLESHOOTING**

### **❌ "Connection refused"**
```
✅ Check server: npm start in backend/
✅ Check port: http://localhost:3000
✅ Check MongoDB: service running
✅ Check Ganache: port 7545
```

### **❌ "Invalid token"**
```
✅ Check token: {{jwt_token}} in environment
✅ Check format: Bearer {{jwt_token}}
✅ Re-login if expired
```

### **❌ "Insufficient balance"**
```
✅ Fund wallets first: /demo/fund-all-users
✅ Check balance: /auction/wallet/balance
✅ Deposit to contract: /auction/wallet/deposit
```

### **❌ Blockchain errors**
```
✅ Check contract deployment
✅ Check ADMIN_PRIVATE_KEY in .env
✅ Check gas limits in Ganache
✅ Verify contract addresses
```

---

## 🎯 **SUCCESS CHECKLIST**

### **Environment Setup:**
- [ ] Postman imported collection
- [ ] Environment variables configured
- [ ] Backend server running
- [ ] MongoDB & Ganache running

### **API Testing:**
- [ ] Authentication: Register/Login ✅
- [ ] Wallet: Fund/Deposit/Withdraw ✅
- [ ] Auction: Create/Bid/Get ✅
- [ ] Payment: Momo Request/Approve ✅

### **Integration Testing:**
- [ ] VND ↔ ETH conversion ✅
- [ ] Blockchain transactions ✅
- [ ] Real-time updates ✅
- [ ] Error handling ✅

---

## 🚀 **QUICK START COMMANDS**

```bash
# 1. Start services
cd backend && npm start

# 2. Import collection vào Postman

# 3. Set environment variables

# 4. Run tests theo thứ tự:
#    Authentication → Auction System → Momo Payment

# 5. Verify results trong Postman console
```

---

## 📞 **SUPPORT**

### **Common Issues:**
- **Token expired**: Re-run login request
- **Balance zero**: Run fund wallets
- **Auction not found**: Create auction first
- **Payment failed**: Check Momo credentials

### **Logs & Debugging:**
- **Server logs**: `backend/server.log`
- **Blockchain**: `blockchain/ganache.log`
- **Postman Console**: View → Show Postman Console

---

**🎉 SUCCESS = All requests return 200 OK with correct data!**</contents>
</xai:function_call">Tạo hướng dẫn chi tiết cách sử dụng Postman để test APIs.


# 🧪 BIDCHAIN API TESTING SUITE

## 📋 **TỔNG QUAN**

Dự án cung cấp **3 cách test APIs**:

1. **📮 Postman Collection** - GUI testing
2. **🔧 Automated Test Script** - Code testing
3. **📖 Manual Testing** - Step-by-step guide

---

## 🎯 **CÁCH 1: POSTMAN (EASIEST)**

### **Import & Run:**
```bash
# 1. Mở Postman
# 2. Import file: BidChain_API_Collection.postman_collection.json
# 3. Setup environment variables
# 4. Run requests theo thứ tự
```

### **Quick Test Flow:**
```
1. Authentication → Register/Login/Fund
2. Auction System → Create/Bid/Deposit
3. Momo Payment → Request/Callback/Approve
4. User Management → Profile/Auctions/Bids
```

---

## ⚙️ **CÁCH 2: AUTOMATED SCRIPT**

### **Run All Tests:**
```bash
cd backend
node test/api_integration_test.js
```

### **Expected Output:**
```
🚀 BIDCHAIN API INTEGRATION TEST SUITE
=====================================

[2025-11-25T...] SUCCESS: Testing Register testuser1...
[2025-11-25T...] SUCCESS: ✅ Register testuser1 PASSED
[2025-11-25T...] SUCCESS: Testing Login testuser1...
[2025-11-25T...] SUCCESS: ✅ Login testuser1 PASSED

... (continues for all endpoints)

=====================================
[2025-11-25T...] SUCCESS: Test suite completed in 45.23 seconds
🎉 ALL API TESTS COMPLETED!
```

---

## 📝 **CÁCH 3: MANUAL CURL TESTING**

### **Authentication:**
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "123456"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "123456"}'
# → Save token from response
```

### **Auction System:**
```bash
# Fund wallets
curl -X POST http://localhost:3000/api/demo/fund-all-users \
  -H "Authorization: Bearer YOUR_TOKEN"

# Create auction
curl -X POST http://localhost:3000/api/auction/create \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "startingPriceWei": "200000000000000000000",
    "stepPriceWei": "10000000000000000000",
    "durationSeconds": 1800,
    "metadataUrl": "ipfs://test"
  }'
```

### **Momo Payment:**
```bash
# Create deposit request
curl -X POST http://localhost:3000/api/payment/deposit/request \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount_vnd": 1000000}'

# Simulate Momo callback
curl -X POST http://localhost:3000/api/payment/momo/callback \
  -H "Content-Type: application/json" \
  -d '{
    "partnerCode": "MOMO_TEST_PARTNER",
    "orderId": "BIDCHAIN_1234567890_testuser",
    "amount": "1000000",
    "resultCode": 0,
    "signature": "mock_signature"
  }'
```

---

## 📊 **TEST RESULTS INTERPRETATION**

### **✅ SUCCESS Indicators:**
```
✅ Register testuser PASSED
✅ Login testuser PASSED
✅ Get Wallet Balance PASSED
✅ Create Auction PASSED
✅ Deposit to Contract PASSED
✅ Place Bid PASSED
✅ Create Deposit Request PASSED
✅ Momo Payment Callback PASSED
✅ Admin Approve Deposit PASSED
```

### **❌ FAILURE Examples:**
```
❌ Create Auction FAILED - 400 Bad Request
❌ Place Bid FAILED - Insufficient balance
❌ Momo Callback FAILED - Invalid signature
```

### **Performance Metrics:**
```
Test suite completed in 45.23 seconds
- Authentication: ~5s
- Auction System: ~15s
- Momo Payment: ~20s
- Blockchain confirmations: ~5s
```

---

## 🔍 **DETAILED API TESTING**

### **Core Endpoints (Must Pass):**
- [ ] **Authentication**: Register/Login/Fund ✅
- [ ] **Wallet**: Balance/Deposit/Withdraw ✅
- [ ] **Auction**: Create/Get/Bid ✅
- [ ] **Payment**: Momo Request/Approve ✅
- [ ] **User**: Profile/Auctions/Bids ✅

### **Blockchain Integration:**
- [ ] **Real ETH Transfers**: Deposit/Withdraw/Settlement ✅
- [ ] **EIP-712 Signatures**: Bid verification ✅
- [ ] **Contract Balance**: Sync với database ✅

### **Conversion Logic:**
- [ ] **VND → ETH**: 1,000,000 VND = 0.02 ETH ✅
- [ ] **ETH → VND**: 0.02 ETH = 1,000,000 VND ✅
- [ ] **Wei Handling**: Correct precision ✅

---

## 🚨 **TROUBLESHOOTING**

### **Common Issues:**

#### **1. "Connection refused"**
```bash
# Check services
✅ Backend: http://localhost:3000
✅ MongoDB: localhost:27017
✅ Ganache: localhost:7545
```

#### **2. "Invalid token"**
```bash
# Re-run authentication
curl -X POST http://localhost:3000/api/auth/login \
  -d '{"username": "testuser", "password": "123456"}'
```

#### **3. "Insufficient balance"**
```bash
# Fund wallets first
curl -X POST http://localhost:3000/api/demo/fund-all-users \
  -H "Authorization: Bearer TOKEN"
```

#### **4. "Auction not found"**
```bash
# Create auction first
curl -X POST http://localhost:3000/api/auction/create \
  -H "Authorization: Bearer TOKEN" \
  -d '{"startingPriceWei": "200000000000000000000", "stepPriceWei": "10000000000000000000", "durationSeconds": 1800}'
```

#### **5. Blockchain Errors**
```bash
# Check contract deployment
✅ Contract address in .env
✅ ADMIN_PRIVATE_KEY configured
✅ Gas limit sufficient
```

---

## 📈 **ADVANCED TESTING**

### **Load Testing:**
```bash
# Test concurrent users
npm install -g artillery
artillery quick --count 50 --num 10 http://localhost:3000/api/auction/all
```

### **Stress Testing:**
```bash
# Test bidding under load
# Simulate 100 users bidding simultaneously
```

### **Integration Testing:**
```bash
# End-to-end user journey
# Register → Fund → Deposit → Bid → Win → Withdraw
```

---

## 🎯 **SUCCESS CRITERIA**

### **Minimum Requirements:**
- [ ] **80% tests pass**
- [ ] **Response time < 2s**
- [ ] **No critical errors**
- [ ] **Blockchain sync working**

### **Full Success:**
- [ ] **100% tests pass**
- [ ] **All conversions accurate**
- [ ] **Real ETH transfers verified**
- [ ] **Production-ready stability**

---

## 📞 **SUPPORT RESOURCES**

### **Files Created:**
- `API_REFERENCE.md` - Complete API documentation
- `POSTMAN_GUIDE.md` - Postman usage guide
- `BidChain_API_Collection.postman_collection.json` - Import file
- `backend/test/api_integration_test.js` - Automated tests

### **Quick Commands:**
```bash
# Full test suite
cd backend && node test/api_integration_test.js

# Individual API test
curl -X GET http://localhost:3000/api/auction/all

# Check server logs
tail -f backend/server.log
```

---

**🎉 Ready to test? Start with Postman for easiest experience!**</contents>
</xai:function_call">Tạo file tổng hợp cách test APIs.


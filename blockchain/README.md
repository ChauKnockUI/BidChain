README (rút gọn, chỉ những gì member khác cần)
# BidChain — Quick Start (simplified)

## Mục đích
Ứng dụng đấu giá demo (Web/Mobile) dùng Smart Contract (Solidity/Hardhat) + Backend (Node.js/Express) + MongoDB.  
Dùng Ganache để demo ETH ảo.

## Cấu trúc
- blockchain/    — Hardhat, contract, scripts/deploy.js
- backend/       — Express API, kết nối blockchain, MongoDB
- frontend/      — Flutter app (tách riêng)

## Yêu cầu
- Node.js 18.x (dùng nvm recommended)
- npm
- Ganache (GUI hoặc CLI) chạy trên `http://127.0.0.1:7545`
- MongoDB (Atlas)
- Postman (để chạy test)

## Thiết lập nhanh (chạy lần đầu)
1. Chuẩn bị Ganache (mở lên, giữ mạng local).
2. Deploy contract và cập nhật backend `.env` (script deploy tự update):
   ```bash
   cd blockchain
   npm install
   npx hardhat run scripts/deploy.js --network ganache


Kết quả tự cập nhật backend/.env với CONTRACT_ADDRESS.

Backend:

cd ../backend
npm install
# Tạo file .env theo mẫu bên dưới (đã có CONTRACT_ADDRESS)
npm run dev

backend/.env (cần có)
    PORT=3000
    MONGO_URI=<your mongo uri>
    JWT_SECRET=<secret>
    GANACHE_RPC=http://127.0.0.1:7545
    CONTRACT_ADDRESS=<auto-updated by deploy script>
    CONTRACT_ABI_PATH=./abi/Auction.json
    MASTER_KEY=<64-hex-chars>

API chính (base = http://localhost:3000)

    POST /api/auth/register
    body: { "username", "password" } → tạo user, tạo ví, trả token

    POST /api/auth/login
    body: { "username", "password" } → trả token

    GET /api/auction/wallet/balance
    Authorization: Bearer <token> → trả { address, balance }

    POST /api/auction/create
    body: { startingPriceWei, durationSeconds, metadataUrl } + Auth → tạo auction trên chain

    POST /api/auction/bid
    body: { auctionId, amountWei } + Auth → đặt giá
## POSTMAN TESTCASES
### Register Seller
    Request

        POST {{baseUrl}}/api/auth/register

        Body (raw JSON):

        {
        "username": "seller1",
        "password": "123456"
        }

 ### Register Buyer
    ➤ Request

        POST {{baseUrl}}/api/auth/register

        Body:

        {
        "username": "buyer1",
        "password": "123456"
        }

   ### Check Seller Balance
    ➤ Request

    GET {{baseUrl}}/api/auction/wallet/balance

    Header:

    Authorization: Bearer {{sellerToken}}

### Check Buyer Balance
    ➤ Request

    GET {{baseUrl}}/api/auction/wallet/balance

    Header:

    Authorization: Bearer {{buyerToken}}

### Create Auction (Seller)
    ➤ Request

    POST {{baseUrl}}/api/auction/create

    Header:

    Authorization: Bearer {{sellerToken}}

    Body:
    {
    "startingPriceWei": "10000000000000000",
    "durationSeconds": 300,
    "metadataUrl": "https://example.com/item1.json"
    }

### Bid (Buyer)
    ➤ Request

    POST {{baseUrl}}/api/auction/bid

    Header:

    Authorization: Bearer {{buyerToken}}

    Body:
    {
    "auctionId": "{{auctionId}}",
    "amountWei": "20000000000000000"
    }

## Bộ test Postman bao gồm:

    Testcase	Mục đích
    Register Seller	Tạo user + ví seller
    Register Buyer	Tạo user + ví buyer
    Check Seller Balance	Kiểm tra ví seller
    Check Buyer Balance	Kiểm tra ví buyer
    Create Auction (seller)	Tạo 1 phiên đấu giá
    Bid (buyer)	Buyer đặt giá

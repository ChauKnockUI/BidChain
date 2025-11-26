/**
 * MOMO PAYMENT DEMO SCRIPT
 * Test complete VND deposit flow with Momo integration
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
let userToken = '';
let adminToken = '';
let depositRequestId = '';

// Test user credentials
const TEST_USER = {
  username: 'testuser',
  password: '123456'
};

const ADMIN_USER = {
  username: 'admin',
  password: 'admin123'
};

class MomoPaymentTester {
  constructor() {
    this.api = axios.create({
      baseURL: BASE_URL,
      timeout: 10000
    });
  }

  async delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async registerAndLogin(user, description) {
    try {
      console.log(`\n📝 ${description}`);

      // Register
      const registerResponse = await this.api.post('/auth/register', user);
      console.log(`✅ Registered ${user.username}`);

      // Login
      const loginResponse = await this.api.post('/auth/login', user);
      console.log(`✅ Logged in ${user.username}`);

      return loginResponse.data.token;
    } catch (error) {
      if (error.response?.status === 400 && error.response?.data?.error?.includes('already exists')) {
        console.log(`ℹ️ ${user.username} already exists, logging in...`);
        const loginResponse = await this.api.post('/auth/login', user);
        return loginResponse.data.token;
      }
      throw error;
    }
  }

  async fundUserWallet(token, description) {
    try {
      console.log(`\n💰 ${description}`);

      const response = await this.api.post('/demo/fund-all-users', {}, {
        headers: { Authorization: `Bearer ${token}` }
      });

      console.log(`✅ Funded users with ETH`);
      return response.data;
    } catch (error) {
      console.log(`❌ Fund wallet failed:`, error.response?.data?.error);
    }
  }

  async createDepositRequest(token, amountVND, description) {
    try {
      console.log(`\n💳 ${description}: ${amountVND.toLocaleString()} VND`);

      const response = await this.api.post('/payment/deposit/request',
        { amount_vnd: amountVND },
        { headers: { Authorization: `Bearer ${token}` } }
      );

      console.log(`✅ Created deposit request`);
      console.log(`   Order ID: ${response.data.momo_payment.order_id}`);
      console.log(`   Pay URL: ${response.data.momo_payment.pay_url}`);
      console.log(`   QR URL: ${response.data.momo_payment.qr_code_url}`);

      depositRequestId = response.data.deposit_request_id;
      return response.data;
    } catch (error) {
      console.log(`❌ Create deposit request failed:`, error.response?.data?.error);
      throw error;
    }
  }

  async simulateMomoPayment(orderId, amount, description) {
    try {
      console.log(`\n📱 ${description}`);

      // Simulate successful Momo payment callback
      const callbackData = {
        partnerCode: 'MOMO_TEST_PARTNER',
        orderId: orderId,
        requestId: orderId,
        amount: amount,
        orderInfo: `Nap tien vao tai khoan dau gia - ${amount.toLocaleString()} VND`,
        orderType: 'momo_wallet',
        transId: `TRANS_${Date.now()}`,
        resultCode: 0, // Success
        message: 'Successful.',
        payType: 'qr',
        responseTime: Date.now(),
        extraData: '',
        signature: 'mock_signature_for_demo' // In real implementation, this would be properly signed
      };

      const response = await this.api.post('/payment/momo/callback', callbackData);
      console.log(`✅ Momo payment callback processed`);
      return response.data;
    } catch (error) {
      console.log(`❌ Momo callback failed:`, error.response?.data?.error);
      throw error;
    }
  }

  async approveDepositRequest(adminToken, requestId, description) {
    try {
      console.log(`\n✅ ${description}`);

      const response = await this.api.post(`/payment/admin/approve-deposit/${requestId}`, {}, {
        headers: { Authorization: `Bearer ${adminToken}` }
      });

      console.log(`✅ Deposit approved and ETH transferred`);
      console.log(`   TX Hash: ${response.data.tx_hash}`);
      return response.data;
    } catch (error) {
      console.log(`❌ Approve deposit failed:`, error.response?.data?.error);
      throw error;
    }
  }

  async checkBalance(token, description) {
    try {
      console.log(`\n💵 ${description}`);

      const response = await this.api.get('/auction/wallet/balance', {
        headers: { Authorization: `Bearer ${token}` }
      });

      console.log(`   Balance: ${response.data.formatted_balance}`);
      console.log(`   Available: ${response.data.formatted_available}`);
      console.log(`   Blockchain: ${response.data.contract_balance_eth} ETH`);

      return response.data;
    } catch (error) {
      console.log(`❌ Check balance failed:`, error.response?.data?.error);
      throw error;
    }
  }

  async checkDepositHistory(token, description) {
    try {
      console.log(`\n📋 ${description}`);

      const response = await this.api.get('/payment/deposit/history', {
        headers: { Authorization: `Bearer ${token}` }
      });

      console.log(`   Found ${response.data.deposit_requests.length} deposit requests`);
      response.data.deposit_requests.slice(0, 3).forEach(req => {
        console.log(`   - ${req.formatted_amount} (${req.status})`);
      });

      return response.data;
    } catch (error) {
      console.log(`❌ Check deposit history failed:`, error.response?.data?.error);
      throw error;
    }
  }

  async runCompleteDemo() {
    console.log('🚀 BIDCHAIN MOMO PAYMENT DEMO');
    console.log('===============================');

    try {
      // Phase 1: Setup Users
      console.log('\n🎯 PHASE 1: USER SETUP');

      userToken = await this.registerAndLogin(TEST_USER, 'Setting up test user');
      adminToken = await this.registerAndLogin(ADMIN_USER, 'Setting up admin user');

      // Phase 2: Fund Wallets (for demo)
      await this.fundUserWallet(adminToken, 'Funding user wallets with ETH');

      await this.delay(2000);

      // Phase 3: Initial Balance Check
      await this.checkBalance(userToken, 'Checking initial balance');

      // Phase 4: Create Deposit Request
      console.log('\n🎯 PHASE 2: VND DEPOSIT REQUEST');

      const depositRequest = await this.createDepositRequest(
        userToken,
        1000000, // 1M VND
        'Creating deposit request for 1,000,000 VND'
      );

      const orderId = depositRequest.momo_payment.order_id;

      // Phase 5: Simulate Momo Payment
      console.log('\n🎯 PHASE 3: MOMO PAYMENT SIMULATION');

      await this.simulateMomoPayment(
        orderId,
        1000000,
        'Simulating successful Momo payment'
      );

      await this.delay(2000);

      // Phase 6: Admin Approval
      console.log('\n🎯 PHASE 4: ADMIN APPROVAL');

      await this.approveDepositRequest(
        adminToken,
        depositRequestId,
        'Admin approving deposit request'
      );

      await this.delay(3000);

      // Phase 7: Final Balance Check
      console.log('\n🎯 PHASE 5: FINAL VERIFICATION');

      await this.checkBalance(userToken, 'Checking final balance after deposit');
      await this.checkDepositHistory(userToken, 'Checking deposit history');

      // Phase 8: Test Deposit to Contract
      console.log('\n🎯 PHASE 6: CONTRACT DEPOSIT TEST');

      const balance = await this.checkBalance(userToken, 'Balance before contract deposit');

      // Now user can deposit VND to contract (this is the separate step)
      console.log('\n💡 Next step: User can now deposit VND to contract for bidding');
      console.log('   This uses the existing /api/auction/wallet/deposit endpoint');

      // Summary
      console.log('\n🎉 MOMO PAYMENT DEMO COMPLETED SUCCESSFULLY!');
      console.log('\n📊 SUMMARY:');
      console.log('✅ User registration & login');
      console.log('✅ VND deposit request creation');
      console.log('✅ Momo QR code generation');
      console.log('✅ Payment simulation (callback)');
      console.log('✅ Admin approval process');
      console.log('✅ ETH transfer to user wallet');
      console.log('✅ Balance updates & verification');
      console.log('✅ Transaction history tracking');

      console.log('\n🔄 COMPLETE FLOW:');
      console.log('1. User → Deposit Request (VND) → Momo QR');
      console.log('2. User → Pay with Momo → Callback to system');
      console.log('3. Admin → Verify & Approve → ETH transfer');
      console.log('4. User → Deposit to Contract → Ready for bidding');

    } catch (error) {
      console.error('\n❌ Demo failed:', error.message);
      console.log('\n🔧 Troubleshooting:');
      console.log('1. Ensure MongoDB and Ganache are running');
      console.log('2. Check .env configuration');
      console.log('3. Verify contract is deployed');
      console.log('4. Check server logs for errors');
    }
  }
}

// Run demo if called directly
if (require.main === module) {
  const tester = new MomoPaymentTester();
  tester.runCompleteDemo();
}

module.exports = MomoPaymentTester;

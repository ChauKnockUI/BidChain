const crypto = require('crypto');
const axios = require('axios');

class MomoService {
  constructor() {
    this.config = {
      partnerCode: process.env.MOMO_PARTNER_CODE || 'MOMO_TEST_PARTNER',
      accessKey: process.env.MOMO_ACCESS_KEY || 'test_access_key',
      secretKey: process.env.MOMO_SECRET_KEY || 'test_secret_key',
      endpoint: process.env.MOMO_ENDPOINT || 'https://test-payment.momo.vn/v2/gateway/api/create',
      callbackUrl: process.env.MOMO_CALLBACK_URL || 'http://localhost:3000/api/payment/momo/callback',
      redirectUrl: process.env.MOMO_REDIRECT_URL || 'http://localhost:3000/payment/success'
    };
  }

  /**
   * Generate Momo QR Code for VND deposit
   * @param {number} amount - Amount in VND
   * @param {string} orderId - Unique order ID
   * @returns {object} Momo payment data
   */
  async createPayment(amount, orderId) {
    const requestId = orderId;
    const orderInfo = `Nap tien vao tai khoan dau gia - ${amount.toLocaleString()} VND`;
    const requestType = 'captureWallet';
    const extraData = '';

    // Create signature
    const rawSignature = `accessKey=${this.config.accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${this.config.callbackUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${this.config.partnerCode}&redirectUrl=${this.config.redirectUrl}&requestId=${requestId}&requestType=${requestType}`;

    const signature = crypto
      .createHmac('sha256', this.config.secretKey)
      .update(rawSignature)
      .digest('hex');

    const paymentData = {
      partnerCode: this.config.partnerCode,
      partnerName: 'BidChain',
      storeId: this.config.partnerCode,
      requestId: requestId,
      amount: amount,
      orderId: orderId,
      orderInfo: orderInfo,
      redirectUrl: this.config.redirectUrl,
      ipnUrl: this.config.callbackUrl,
      lang: 'vi',
      requestType: requestType,
      autoCapture: true,
      extraData: extraData,
      signature: signature
    };

    try {
      const response = await axios.post(this.config.endpoint, paymentData, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (response.data.resultCode === 0) {
        return {
          success: true,
          payUrl: response.data.payUrl,
          qrCodeUrl: response.data.qrCodeUrl || this.generateQRCodeUrl(orderId, amount),
          deeplink: response.data.deeplink,
          orderId: orderId
        };
      } else {
        return {
          success: false,
          error: response.data.message,
          resultCode: response.data.resultCode
        };
      }
    } catch (error) {
      console.error('Momo payment creation failed:', error);
      return {
        success: false,
        error: 'Failed to create payment'
      };
    }
  }

  /**
   * Verify Momo callback signature
   * @param {object} callbackData - Callback data from Momo
   * @returns {boolean} Signature valid
   */
  verifyCallback(callbackData) {
    const {
      partnerCode,
      orderId,
      requestId,
      amount,
      orderInfo,
      orderType,
      transId,
      resultCode,
      message,
      payType,
      responseTime,
      extraData
    } = callbackData;

    const rawSignature = `partnerCode=${partnerCode}&orderId=${orderId}&requestId=${requestId}&amount=${amount}&orderInfo=${orderInfo}&orderType=${orderType}&transId=${transId}&resultCode=${resultCode}&message=${message}&payType=${payType}&responseTime=${responseTime}&extraData=${extraData}`;

    const signature = crypto
      .createHmac('sha256', this.config.secretKey)
      .update(rawSignature)
      .digest('hex');

    return signature === callbackData.signature;
  }

  /**
   * Generate QR Code URL for demo purposes
   * @param {string} orderId - Order ID
   * @param {number} amount - Amount
   * @returns {string} QR Code URL
   */
  generateQRCodeUrl(orderId, amount) {
    // For demo, generate a mock QR code URL
    // In production, Momo provides real QR codes
    const qrData = `MOMO_DEMO:${orderId}:${amount}`;
    return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrData)}`;
  }

  /**
   * Process successful payment
   * @param {object} callbackData - Momo callback data
   * @returns {object} Processing result
   */
  processPaymentSuccess(callbackData) {
    const { orderId, transId, amount, resultCode } = callbackData;

    if (resultCode === 0) {
      return {
        success: true,
        orderId,
        transactionId: transId,
        amount: parseInt(amount),
        status: 'PAID'
      };
    } else {
      return {
        success: false,
        orderId,
        error: 'Payment failed',
        resultCode,
        status: 'FAILED'
      };
    }
  }
}

module.exports = new MomoService();

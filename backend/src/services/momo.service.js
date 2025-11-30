const crypto = require('crypto');
const axios = require('axios');
const config = require('../config/momo');

class MomoService {
  createSignature(rawSignature) {
    return crypto
      .createHmac('sha256', config.secretKey)
      .update(rawSignature)
      .digest('hex');
  }

  // ================================
  // 💳 Tạo đơn thanh toán MoMo
  // ================================
  async createPayment(amount, orderId) {
    const requestId = `REQ_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const rawSignature =
      `accessKey=${config.accessKey}` +
      `&amount=${amount}` +
      `&extraData=${config.extraData}` +
      `&ipnUrl=${config.ipnUrl}` +
      `&orderId=${orderId}` +
      `&orderInfo=${config.orderInfo}` +
      `&partnerCode=${config.partnerCode}` +
      `&redirectUrl=${config.redirectUrl}` +
      `&requestId=${requestId}` +
      `&requestType=${config.requestType}`;

    const signature = this.createSignature(rawSignature);

    const requestBody = {
      partnerCode: config.partnerCode,
      partnerName: "MoMo Test",
      storeId: "MoMoTestStore",
      requestId,
      amount: amount.toString(),
      orderId,
      orderInfo: config.orderInfo,
      redirectUrl: config.redirectUrl,
      ipnUrl: config.ipnUrl,
      requestType: config.requestType,
      autoCapture: config.autoCapture,
      lang: config.lang,
      extraData: config.extraData,
      signature
    };

    try {
      const response = await axios.post(
        "https://test-payment.momo.vn/v2/gateway/api/create",
        requestBody,
        { headers: { "Content-Type": "application/json" } }
      );

      console.log("MoMo Create Response:", JSON.stringify(response.data, null, 2));

      if (response.status !== 200 || response.data.resultCode !== 0) {
        return {
          success: false,
          error: response.data.message || "MoMo trả về lỗi"
        };
      }

      return {
        success: true,
        ...response.data,
        qrCodeUrl: response.data.qrCodeUrl || "",
        payUrl: response.data.payUrl || ""
      };
    } catch (err) {
      console.error("MoMo create error:", err.response?.data || err.message);
      return {
        success: false,
        error: err.response?.data?.message || "Network/Request error"
      };
    }
  }

  // ================================
  // 🔍 Query trạng thái giao dịch (dùng cho auto-check/manual)
  // ================================
  async checkTransactionStatus(orderId) {
    const requestId = `QUERY_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const rawSignature =
      `accessKey=${config.accessKey}` +
      `&orderId=${orderId}` +
      `&partnerCode=${config.partnerCode}` +
      `&requestId=${requestId}`;

    console.log("Query rawSignature:", rawSignature);

    const signature = this.createSignature(rawSignature);
    console.log("Generated signature:", signature);  // Debug signature

    const body = {
      partnerCode: config.partnerCode,
      requestId,
      orderId,
      signature,
      lang: "vi"
    };

    try {
      const response = await axios.post(
        "https://test-payment.momo.vn/v2/gateway/api/query",
        body,
        { headers: { "Content-Type": "application/json" } }
      );

      console.log("MoMo query response:", response.data);
      return response.data;

    } catch (err) {
      console.error("MoMo query error:", err.response?.data || err.message);
      return { resultCode: -1, message: "Query failed" };
    }
  }

  // ================================
  // 🔐 Xác minh chữ ký callback IPN/Redirect
  // ================================
  verifyCallback(callbackData) {
    const rawSignature =
      `accessKey=${config.accessKey}` +
      `&amount=${callbackData.amount}` +
      `&extraData=${callbackData.extraData || ''}` +
      `&message=${callbackData.message}` +
      `&orderId=${callbackData.orderId}` +
      `&orderInfo=${callbackData.orderInfo}` +
      `&orderType=${callbackData.orderType}` +
      `&partnerCode=${callbackData.partnerCode}` +
      `&payType=${callbackData.payType}` +
      `&requestId=${callbackData.requestId}` +
      `&responseTime=${callbackData.responseTime}` +
      `&resultCode=${callbackData.resultCode}` +
      `&transId=${callbackData.transId}`;

    const signature = this.createSignature(rawSignature);
    console.log("Callback verify - Generated sig:", signature, "vs received:", callbackData.signature); // Debug
    return signature === callbackData.signature;
  }

  // ================================
  // 🧾 Xử lý kết quả thanh toán (helper, nếu cần)
  // ================================
  processPaymentSuccess(callbackData) {
    if (callbackData.resultCode === 0) {
      return {
        success: true,
        transId: callbackData.transId
      };
    }

    return {
      success: false,
      error: callbackData.message || "Payment failed"
    };
  }
}

module.exports = new MomoService();
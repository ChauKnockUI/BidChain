class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Auction endpoints
  static const String getAuctions = '/auction/all';
  static const String getAuctionDetail = '/auction';
  static const String createAuction = '/auction/create';
  static const String placeBid = '/auction/bid';
  static const String endAuction = '/auction';
  static const String confirmReceipt = '/confirm';

  // Wallet endpoints
  static const String getBalance = '/auction/wallet/balance';
  static const String withdraw = '/auction/wallet/withdraw';

  // User endpoints
  static const String getUserProfile = '/user/me';
  static const String updateUserProfile = '/user/me';
  static const String getUserAuctions = '/user/me/auctions';
  static const String getUserBids = '/user/me/bids';
  static const String uploadAvatar = '/upload/avatar/update';

  // Auth endpoints (continued)
  static const String changePassword = '/auth/change-password';

  // Category endpoints
  static const String getCategories = '/category/all';

  // Upload endpoints
  static const String uploadImages = '/upload/ipfs/multiple';
}

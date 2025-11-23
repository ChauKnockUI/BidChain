class AppConstants {
  static const String appName = 'BidChain';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String ethAddressKey = 'eth_address';

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration debounceTime = Duration(milliseconds: 500);

  // Pagination
  static const int pageSize = 10;

  // Blockchain
  static const String networkName = 'Ganache';
  static const String chainId = '5777';
}
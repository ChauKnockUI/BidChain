import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    required super.role,
    required super.walletAddress,
    super.balanceEth,
    super.lockedEth,
    super.lastNonce,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'USER',
      walletAddress: json['wallet_address'] ?? '',
      balanceEth: _parseBalance(json['balance_eth']),
      lockedEth: _parseBalance(json['locked_eth']),
      lastNonce: json['last_nonce'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'wallet_address': walletAddress,
      'balance_eth': balanceEth,
      'locked_eth': lockedEth,
      'last_nonce': lastNonce,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Parse balance from backend
  /// - If number (num): already ETH from login response (parseFloat on backend)
  /// - If string: always Wei from database, need to convert to ETH
  static double _parseBalance(dynamic value) {
    if (value == null) return 0.0;
    
    // If it's a number, it's already ETH (from login/register response)
    if (value is num) {
      return value.toDouble();
    }
    
    // If it's a string, it's Wei from database - always convert to ETH
    if (value is String) {
      if (value.isEmpty) return 0.0;
      try {
        // Parse Wei string and convert to ETH: value / 10^18
        final weiValue = double.parse(value);
        return weiValue / 1000000000000000000.0;
      } catch (e) {
        print('Error parsing Wei balance: $e');
        return 0.0;
      }
    }
    return 0.0;
  }
}
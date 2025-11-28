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
      balanceEth: _parseWei(json['balance_eth']),
      lockedEth: _parseWei(json['locked_eth']),
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
      'balance_eth': balanceEth, // Note: This saves as ETH double, not Wei string
      'locked_eth': lockedEth,
      'last_nonce': lastNonce,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static double _parseWei(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return 0.0;
      try {
        // Backend returns Wei as string (e.g., "3000000000000000000")
        // Convert Wei to ETH: value / 10^18
        return double.parse(value) / 1000000000000000000.0;
      } catch (e) {
        print('Error parsing Wei: $e');
        return 0.0;
      }
    }
    return 0.0;
  }
}
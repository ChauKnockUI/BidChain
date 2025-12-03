import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    required super.role,
    required super.walletAddress,
    super.avatar,
    super.momoPhone,
    super.balanceEth,
    super.lockedEth,
    super.lastNonce,
    required super.createdAt,
    super.country,
    super.city,
    super.district,
    super.ward,
    super.address,
    super.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'USER',
      walletAddress: json['wallet_address'] ?? '',
      avatar: json['avatar'],
      momoPhone: json['momo_phone'],
      balanceEth: _parseWei(json['balance_eth']),
      lockedEth: _parseWei(json['locked_eth']),
      lastNonce: json['last_nonce'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      country: json['country'],
      city: json['city'],
      district: json['district'],
      ward: json['ward'],
      address: json['address'],
      bio: json['bio'],
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
      'avatar': avatar,
      'momo_phone': momoPhone,
      'balance_eth': balanceEth,
      'locked_eth': lockedEth,
      'last_nonce': lastNonce,
      'created_at': createdAt.toIso8601String(),
      'country': country,
      'city': city,
      'district': district,
      'ward': ward,
      'address': address,
      'bio': bio,
    };
  }

  /// Parse balance from backend
  /// - If number (num): already ETH from login response (parseFloat on backend)
  /// - If string: always Wei from database, need to convert to ETH
  static double _parseWei(dynamic value) {
    if (value == null) return 0.0;

    // If it's a number, it's already ETH (from login/register response)
    if (value is num) {
      return value.toDouble();
    }

    // If it's a string, it's Wei from database - always convert to ETH
    if (value is String) {
      if (value.isEmpty) return 0.0;
      try {
        return double.parse(value) / 1000000000000000000.0;
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

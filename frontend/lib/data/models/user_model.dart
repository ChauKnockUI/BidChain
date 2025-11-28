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
      balanceEth: (json['balance_eth'] is num)
          ? (json['balance_eth'] as num).toDouble()
          : 0.0,
      lockedEth: (json['locked_eth'] is num)
          ? (json['locked_eth'] as num).toDouble()
          : 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
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
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
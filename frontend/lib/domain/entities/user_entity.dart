import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String walletAddress;
  final String? avatar;
  final double balanceEth;
  final double lockedEth;
  final int lastNonce;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.walletAddress,
    this.avatar,
    this.balanceEth = 0.0,
    this.lockedEth = 0.0,
    this.lastNonce = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    fullName,
    role,
    walletAddress,
    avatar,
    balanceEth,
    lockedEth,
    lastNonce,
    createdAt,
  ];
}
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String walletAddress;
  final String? avatar;
  final String? momoPhone;
  final double balanceEth;
  final double lockedEth;
  final int lastNonce;
  final DateTime createdAt;
  final String? country;
  final String? city;
  final String? district;
  final String? ward;
  final String? address;
  final String? bio;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    required this.walletAddress,
    this.avatar,
    this.momoPhone,
    this.balanceEth = 0.0,
    this.lockedEth = 0.0,
    this.lastNonce = 0,
    required this.createdAt,
    this.country,
    this.city,
    this.district,
    this.ward,
    this.address,
    this.bio,
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
    momoPhone,
    balanceEth,
    lockedEth,
    lastNonce,
    createdAt,
    country,
    city,
    district,
    ward,
    address,
    bio,
  ];
}

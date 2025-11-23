import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String address;
  final String balanceWei; // Wei
  final String balanceEther;

  const WalletEntity({
    required this.address,
    required this.balanceWei,
    required this.balanceEther,
  });

  @override
  List<Object?> get props => [address, balanceWei, balanceEther];
}
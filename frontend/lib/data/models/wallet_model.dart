import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required String address,
    required String balanceWei,
    required String balanceEther,
  }) : super(
    address: address,
    balanceWei: balanceWei,
    balanceEther: balanceEther,
  );

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      address: json['address'] ?? '',
      balanceWei: json['balance']?.toString() ?? '0',
      balanceEther: json['balanceEther'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'balance': balanceWei,
      'balanceEther': balanceEther,
    };
  }
}
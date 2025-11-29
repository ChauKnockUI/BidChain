import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String id;
  final String auctionId;
  final String userId;
  final String userName;
  final double amountVnd;
  final String formattedAmount;
  final String status;
  final DateTime createdAt;

  const BidEntity({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.userName,
    required this.amountVnd,
    required this.formattedAmount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    auctionId,
    userId,
    userName,
    amountVnd,
    formattedAmount,
    status,
    createdAt,
  ];
}

import 'package:equatable/equatable.dart';

abstract class AuctionDetailEvent extends Equatable {
  const AuctionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadAuctionDetail extends AuctionDetailEvent {
  final String auctionId;

  const LoadAuctionDetail({required this.auctionId});

  @override
  List<Object?> get props => [auctionId];
}

class RefreshAuctionDetail extends AuctionDetailEvent {
  final String auctionId;

  const RefreshAuctionDetail({required this.auctionId});

  @override
  List<Object?> get props => [auctionId];
}

class PlaceBid extends AuctionDetailEvent {
  final String auctionId;
  final double amountVnd;

  const PlaceBid({required this.auctionId, required this.amountVnd});

  @override
  List<Object?> get props => [auctionId, amountVnd];
}

class ConfirmReceiptEvent extends AuctionDetailEvent {
  final String auctionId;

  const ConfirmReceiptEvent(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

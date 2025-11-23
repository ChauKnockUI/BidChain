import 'package:equatable/equatable.dart';

class AuctionEntity extends Equatable {
  final String auctionId;
  final String seller;
  final String startingPrice; // Wei
  final String highestBid; // Wei
  final String highestBidder;
  final DateTime endTime;
  final String metadataUrl;
  final bool ended;
  final String? winner;
  final DateTime createdAt;

  const AuctionEntity({
    required this.auctionId,
    required this.seller,
    required this.startingPrice,
    required this.highestBid,
    required this.highestBidder,
    required this.endTime,
    required this.metadataUrl,
    required this.ended,
    this.winner,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    auctionId,
    seller,
    startingPrice,
    highestBid,
    highestBidder,
    endTime,
    metadataUrl,
    ended,
    winner,
    createdAt,
  ];
}
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
  final String title;
  final String description;
  final List<String> images;
  final String formattedCurrentPrice;
  final String sellerName;
  final int bidCount;
  final String? categoryId;
  final String status;

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
    required this.title,
    required this.description,
    required this.images,
    required this.formattedCurrentPrice,
    required this.sellerName,
    required this.bidCount,
    this.categoryId,
    required this.status,
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
    title,
    description,
    images,
    formattedCurrentPrice,
    sellerName,
    bidCount,
    categoryId,
    status,
  ];

  bool get isActive => status == 'ACTIVE' || status == 'APPROVED';
}

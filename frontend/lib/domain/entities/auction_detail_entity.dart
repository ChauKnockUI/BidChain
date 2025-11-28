import 'package:equatable/equatable.dart';
import 'bid_entity.dart';

class AuctionDetailEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String status;
  final String sellerId;
  final String sellerName;
  final String? sellerEmail;
  final double startPriceVnd;
  final double currentPriceVnd;
  final double stepPriceVnd;
  final String formattedStartPrice;
  final String formattedCurrentPrice;
  final String formattedStepPrice;
  final String? highestBidderId;
  final String? highestBidderName;
  final DateTime? startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final List<BidEntity> bids;
  final String? categoryId;

  const AuctionDetailEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    this.sellerEmail,
    required this.startPriceVnd,
    required this.currentPriceVnd,
    required this.stepPriceVnd,
    required this.formattedStartPrice,
    required this.formattedCurrentPrice,
    required this.formattedStepPrice,
    this.highestBidderId,
    this.highestBidderName,
    this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.bids,
    this.categoryId,
  });

  bool get isActive => status == 'ACTIVE';
  bool get hasEnded => status == 'ENDED' || status == 'SETTLED';
  int get bidCount => bids.length;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    images,
    status,
    sellerId,
    sellerName,
    sellerEmail,
    startPriceVnd,
    currentPriceVnd,
    stepPriceVnd,
    formattedStartPrice,
    formattedCurrentPrice,
    formattedStepPrice,
    highestBidderId,
    highestBidderName,
    startTime,
    endTime,
    createdAt,
    bids,
    categoryId,
  ];
}

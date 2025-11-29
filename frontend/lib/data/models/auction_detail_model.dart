import '../../domain/entities/auction_detail_entity.dart';
import '../../domain/entities/bid_entity.dart';
import 'bid_model.dart';

class AuctionDetailModel extends AuctionDetailEntity {
  const AuctionDetailModel({
    required super.id,
    required super.title,
    required super.description,
    required super.images,
    required super.status,
    required super.sellerId,
    required super.sellerName,
    super.sellerEmail,
    required super.startPriceVnd,
    required super.currentPriceVnd,
    required super.stepPriceVnd,
    required super.formattedStartPrice,
    required super.formattedCurrentPrice,
    required super.formattedStepPrice,
    super.highestBidderId,
    super.highestBidderName,
    super.startTime,
    required super.endTime,
    required super.createdAt,
    required super.bids,
    super.categoryId,
  });

  factory AuctionDetailModel.fromJson(Map<String, dynamic> json) {
    // Parse bids
    List<BidEntity> bidsList = [];
    if (json['bids'] != null && json['bids'] is List) {
      bidsList = (json['bids'] as List)
          .map((bid) => BidModel.fromJson(bid))
          .toList();
    }

    return AuctionDetailModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? 'PENDING_APPROVAL',
      sellerId:
          json['seller_id']?['_id']?.toString() ??
          json['seller_id']?.toString() ??
          '',
      sellerName: json['seller_id']?['full_name'] ?? 'Unknown Seller',
      sellerEmail: json['seller_id']?['email'],
      startPriceVnd: (json['start_price_vnd'] ?? 0).toDouble(),
      currentPriceVnd: (json['current_price_vnd'] ?? 0).toDouble(),
      stepPriceVnd: (json['step_price_vnd'] ?? 0).toDouble(),
      formattedStartPrice: json['formatted_start_price'] ?? '0 ₫',
      formattedCurrentPrice: json['formatted_current_price'] ?? '0 ₫',
      formattedStepPrice: json['formatted_step_price'] ?? '0 ₫',
      highestBidderId:
          json['highest_bidder_id']?['_id']?.toString() ??
          json['highest_bidder_id']?.toString(),
      highestBidderName: json['highest_bidder_id']?['full_name'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      bids: bidsList,
      categoryId: json['category_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'images': images,
      'status': status,
      'seller_id': sellerId,
      'start_price_vnd': startPriceVnd,
      'current_price_vnd': currentPriceVnd,
      'step_price_vnd': stepPriceVnd,
      'formatted_start_price': formattedStartPrice,
      'formatted_current_price': formattedCurrentPrice,
      'formatted_step_price': formattedStepPrice,
      'highest_bidder_id': highestBidderId,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'category_id': categoryId,
    };
  }
}

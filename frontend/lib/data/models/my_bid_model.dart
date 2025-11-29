import '../../domain/entities/my_bid_entity.dart';

class MyBidModel extends MyBidEntity {
  const MyBidModel({
    required super.auctionId,
    required super.title,
    required super.images,
    required super.status,
    required super.myBidAmount,
    required super.formattedMyBid,
    required super.currentPrice,
    required super.formattedCurrentPrice,
    required super.bidStatus,
    required super.bidTime,
    required super.endTime,
    required super.isWinner,
  });

  factory MyBidModel.fromJson(Map<String, dynamic> json) {
    return MyBidModel(
      auctionId: json['auction_id']?.toString() ?? '',
      title: json['title'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? 'ACTIVE',
      myBidAmount: (json['my_bid_amount'] ?? 0).toDouble(),
      formattedMyBid: json['formatted_my_bid'] ?? '0 ₫',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      formattedCurrentPrice: json['formatted_current_price'] ?? '0 ₫',
      bidStatus: json['bid_status'] ?? 'VALID',
      bidTime: json['bid_time'] != null
          ? DateTime.parse(json['bid_time'])
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now(),
      isWinner: json['is_winner'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auction_id': auctionId,
      'title': title,
      'images': images,
      'status': status,
      'my_bid_amount': myBidAmount,
      'formatted_my_bid': formattedMyBid,
      'current_price': currentPrice,
      'formatted_current_price': formattedCurrentPrice,
      'bid_status': bidStatus,
      'bid_time': bidTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_winner': isWinner,
    };
  }
}

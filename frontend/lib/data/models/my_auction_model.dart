import '../../domain/entities/my_auction_entity.dart';

class MyAuctionModel extends MyAuctionEntity {
  const MyAuctionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.images,
    required super.status,
    required super.startPriceVnd,
    required super.currentPriceVnd,
    required super.formattedStartPrice,
    required super.formattedCurrentPrice,
    required super.endTime,
    super.highestBidder,
  });

  factory MyAuctionModel.fromJson(Map<String, dynamic> json) {
    return MyAuctionModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? 'PENDING_APPROVAL',
      startPriceVnd: (json['start_price_vnd'] ?? 0).toDouble(),
      currentPriceVnd: (json['current_price_vnd'] ?? 0).toDouble(),
      formattedStartPrice: json['formatted_start_price'] ?? '0 ₫',
      formattedCurrentPrice: json['formatted_current_price'] ?? '0 ₫',
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now(),
      highestBidder: json['highest_bidder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'images': images,
      'status': status,
      'start_price_vnd': startPriceVnd,
      'current_price_vnd': currentPriceVnd,
      'formatted_start_price': formattedStartPrice,
      'formatted_current_price': formattedCurrentPrice,
      'end_time': endTime.toIso8601String(),
      'highest_bidder': highestBidder,
    };
  }
}

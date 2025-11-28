import '../../domain/entities/auction_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'user_model.dart';

class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.images,
    required super.status,
    required super.startPriceVnd,
    required super.currentPriceVnd,
    required super.stepPriceVnd,
    super.formattedCurrentPrice,
    required super.endTime,
    super.seller,
    super.highestBidder,
    required super.createdAt,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      status: json['status'] ?? '',
      startPriceVnd: _parseDouble(json['start_price_vnd']),
      currentPriceVnd: _parseDouble(json['current_price_vnd']),
      stepPriceVnd: _parseDouble(json['step_price_vnd']),
      formattedCurrentPrice: json['formatted_current_price'],
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now().add(const Duration(days: 1)),
      seller: json['seller_id'] != null
          ? UserModel.fromJson(json['seller_id']) // Assuming UserModel can handle partial data
          : null,
      highestBidder: json['highest_bidder_id'] != null
          ? UserModel.fromJson(json['highest_bidder_id'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
      'step_price_vnd': stepPriceVnd,
      'formatted_current_price': formattedCurrentPrice,
      'end_time': endTime.toIso8601String(),
      // Note: seller and highestBidder serialization might need adjustment based on backend expectation for updates
      'created_at': createdAt.toIso8601String(),
    };
  }
}
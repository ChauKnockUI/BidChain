import '../../domain/entities/bid_entity.dart';

class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.auctionId,
    required super.userId,
    required super.userName,
    required super.amountVnd,
    required super.formattedAmount,
    required super.status,
    required super.createdAt,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['_id']?.toString() ?? '',
      auctionId: json['auction_id']?.toString() ?? '',
      userId:
          json['user_id']?['_id']?.toString() ??
          json['user_id']?.toString() ??
          '',
      userName: json['user_id']?['full_name'] ?? 'Unknown',
      amountVnd: (json['amount_vnd'] ?? 0).toDouble(),
      formattedAmount: json['formatted_amount'] ?? '0 ₫',
      status: json['status'] ?? 'VALID',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'auction_id': auctionId,
      'user_id': userId,
      'amount_vnd': amountVnd,
      'formatted_amount': formattedAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

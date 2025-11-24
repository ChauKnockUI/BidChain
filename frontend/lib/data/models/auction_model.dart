import '../../domain/entities/auction_entity.dart';

class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required super.auctionId,
    required super.seller,
    required super.startingPrice,
    required super.highestBid,
    required super.highestBidder,
    required super.endTime,
    required super.metadataUrl,
    required super.ended,
    super.winner,
    required super.createdAt,
  });

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      auctionId: json['auctionId']?.toString() ?? '',
      seller: json['seller'] ?? '',
      startingPrice: json['startingPrice'] ?? '0',
      highestBid: json['highestBid'] ?? '0',
      highestBidder: json['highestBidder'] ?? '',
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      metadataUrl: json['metadataUrl'] ?? '',
      ended: json['ended'] ?? false,
      winner: json['winner'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auctionId': auctionId,
      'seller': seller,
      'startingPrice': startingPrice,
      'highestBid': highestBid,
      'highestBidder': highestBidder,
      'endTime': endTime.toIso8601String(),
      'metadataUrl': metadataUrl,
      'ended': ended,
      'winner': winner,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
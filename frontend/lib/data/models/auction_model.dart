import '../../domain/entities/auction_entity.dart';

class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required String auctionId,
    required String seller,
    required String startingPrice,
    required String highestBid,
    required String highestBidder,
    required DateTime endTime,
    required String metadataUrl,
    required bool ended,
    String? winner,
    required DateTime createdAt,
  }) : super(
    auctionId: auctionId,
    seller: seller,
    startingPrice: startingPrice,
    highestBid: highestBid,
    highestBidder: highestBidder,
    endTime: endTime,
    metadataUrl: metadataUrl,
    ended: ended,
    winner: winner,
    createdAt: createdAt,
  );

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
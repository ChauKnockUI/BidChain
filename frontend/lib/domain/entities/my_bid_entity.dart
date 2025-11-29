import 'package:equatable/equatable.dart';

class MyBidEntity extends Equatable {
  final String auctionId;
  final String title;
  final List<String> images;
  final String status;
  final double myBidAmount;
  final String formattedMyBid;
  final double currentPrice;
  final String formattedCurrentPrice;
  final String bidStatus;
  final DateTime bidTime;
  final DateTime endTime;
  final bool isWinner;

  const MyBidEntity({
    required this.auctionId,
    required this.title,
    required this.images,
    required this.status,
    required this.myBidAmount,
    required this.formattedMyBid,
    required this.currentPrice,
    required this.formattedCurrentPrice,
    required this.bidStatus,
    required this.bidTime,
    required this.endTime,
    required this.isWinner,
  });

  @override
  List<Object?> get props => [
    auctionId,
    title,
    images,
    status,
    myBidAmount,
    formattedMyBid,
    currentPrice,
    formattedCurrentPrice,
    bidStatus,
    bidTime,
    endTime,
    isWinner,
  ];
}

import 'package:equatable/equatable.dart';

class MyAuctionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String status;
  final double startPriceVnd;
  final double currentPriceVnd;
  final String formattedStartPrice;
  final String formattedCurrentPrice;
  final DateTime endTime;
  final String? highestBidder;

  const MyAuctionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.status,
    required this.startPriceVnd,
    required this.currentPriceVnd,
    required this.formattedStartPrice,
    required this.formattedCurrentPrice,
    required this.endTime,
    this.highestBidder,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    images,
    status,
    startPriceVnd,
    currentPriceVnd,
    formattedStartPrice,
    formattedCurrentPrice,
    endTime,
    highestBidder,
  ];
}

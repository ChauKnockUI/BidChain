import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuctionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String status;
  final double startPriceVnd;
  final double currentPriceVnd;
  final double stepPriceVnd;
  final String? formattedCurrentPrice;
  final DateTime endTime;
  final UserEntity? seller;
  final UserEntity? highestBidder;
  final DateTime createdAt;

  const AuctionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.status,
    required this.startPriceVnd,
    required this.currentPriceVnd,
    required this.stepPriceVnd,
    this.formattedCurrentPrice,
    required this.endTime,
    this.seller,
    this.highestBidder,
    required this.createdAt,
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
    stepPriceVnd,
    formattedCurrentPrice,
    endTime,
    seller,
    highestBidder,
    createdAt,
  ];
}
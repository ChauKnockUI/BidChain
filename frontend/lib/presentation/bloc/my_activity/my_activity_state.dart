import 'package:equatable/equatable.dart';
import '../../../domain/entities/my_auction_entity.dart';
import '../../../domain/entities/my_bid_entity.dart';

abstract class MyActivityState extends Equatable {
  const MyActivityState();

  @override
  List<Object?> get props => [];
}

class MyActivityInitial extends MyActivityState {
  const MyActivityInitial();
}

class MyActivityLoading extends MyActivityState {
  const MyActivityLoading();
}

class MyActivityLoaded extends MyActivityState {
  final List<MyAuctionEntity> auctions;
  final List<MyBidEntity> bids;

  const MyActivityLoaded({required this.auctions, required this.bids});

  @override
  List<Object?> get props => [auctions, bids];
}

class MyActivityError extends MyActivityState {
  final String message;

  const MyActivityError({required this.message});

  @override
  List<Object?> get props => [message];
}

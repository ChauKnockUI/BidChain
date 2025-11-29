import 'package:equatable/equatable.dart';
import '../../../domain/entities/auction_entity.dart';

abstract class AuctionState extends Equatable {
  const AuctionState();

  @override
  List<Object> get props => [];
}

class AuctionInitial extends AuctionState {}

class AuctionLoading extends AuctionState {}

class AuctionLoaded extends AuctionState {
  final List<AuctionEntity> auctions;

  const AuctionLoaded(this.auctions);

  @override
  List<Object> get props => [auctions];
}

class AuctionError extends AuctionState {
  final String message;

  const AuctionError(this.message);

  @override
  List<Object> get props => [message];
}

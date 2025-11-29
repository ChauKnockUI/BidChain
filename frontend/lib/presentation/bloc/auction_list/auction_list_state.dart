import 'package:equatable/equatable.dart';
import '../../../data/models/auction_model.dart';

abstract class AuctionListState extends Equatable {
  const AuctionListState();

  @override
  List<Object> get props => [];
}

class AuctionListInitial extends AuctionListState {}

class AuctionListLoading extends AuctionListState {}

class AuctionListLoaded extends AuctionListState {
  final List<AuctionModel> auctions;

  const AuctionListLoaded({required this.auctions});

  @override
  List<Object> get props => [auctions];
}

class AuctionListError extends AuctionListState {
  final String message;

  const AuctionListError({required this.message});

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../../../domain/entities/auction_detail_entity.dart';

abstract class AuctionDetailState extends Equatable {
  const AuctionDetailState();

  @override
  List<Object?> get props => [];
}

class AuctionDetailInitial extends AuctionDetailState {
  const AuctionDetailInitial();
}

class AuctionDetailLoading extends AuctionDetailState {
  const AuctionDetailLoading();
}

class AuctionDetailLoaded extends AuctionDetailState {
  final AuctionDetailEntity auction;

  const AuctionDetailLoaded({required this.auction});

  @override
  List<Object?> get props => [auction];
}

class AuctionDetailError extends AuctionDetailState {
  final String message;

  const AuctionDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BidPlacing extends AuctionDetailState {
  final AuctionDetailEntity auction;

  const BidPlacing({required this.auction});

  @override
  List<Object?> get props => [auction];
}

class BidPlaced extends AuctionDetailState {
  final AuctionDetailEntity auction;
  final String message;

  const BidPlaced({required this.auction, required this.message});

  @override
  List<Object?> get props => [auction, message];
}

class BidError extends AuctionDetailState {
  final AuctionDetailEntity auction;
  final String message;

  const BidError({required this.auction, required this.message});

  @override
  List<Object?> get props => [auction, message];
}

class ReceiptConfirming extends AuctionDetailState {
  final AuctionDetailEntity auction;

  const ReceiptConfirming({required this.auction});

  @override
  List<Object?> get props => [auction];
}

class ReceiptConfirmed extends AuctionDetailState {
  final AuctionDetailEntity auction;
  final String message;

  const ReceiptConfirmed({required this.auction, required this.message});

  @override
  List<Object?> get props => [auction, message];
}

class ReceiptError extends AuctionDetailState {
  final AuctionDetailEntity auction;
  final String message;

  const ReceiptError({required this.auction, required this.message});

  @override
  List<Object?> get props => [auction, message];
}

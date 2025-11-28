import 'package:equatable/equatable.dart';

abstract class AuctionEvent extends Equatable {
  const AuctionEvent();

  @override
  List<Object> get props => [];
}

class GetAuctions extends AuctionEvent {}

class RefreshAuctions extends AuctionEvent {}

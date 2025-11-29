import 'package:equatable/equatable.dart';

abstract class AuctionListEvent extends Equatable {
  const AuctionListEvent();

  @override
  List<Object> get props => [];
}

class LoadAuctions extends AuctionListEvent {
  const LoadAuctions();
}

class RefreshAuctions extends AuctionListEvent {
  const RefreshAuctions();
}

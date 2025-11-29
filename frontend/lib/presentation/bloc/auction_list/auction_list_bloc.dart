import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auction_repository.dart';
import '../../../data/models/auction_model.dart';
import 'auction_list_event.dart';
import 'auction_list_state.dart';

class AuctionListBloc extends Bloc<AuctionListEvent, AuctionListState> {
  final AuctionRepository repository;

  AuctionListBloc({required this.repository}) : super(AuctionListInitial()) {
    on<LoadAuctions>(_onLoadAuctions);
    on<RefreshAuctions>(_onRefreshAuctions);
  }

  Future<void> _onLoadAuctions(
    LoadAuctions event,
    Emitter<AuctionListState> emit,
  ) async {
    emit(AuctionListLoading());
    final result = await repository.getAuctions();
    result.fold(
      (failure) => emit(AuctionListError(message: failure.message)),
      (auctions) =>
          emit(AuctionListLoaded(auctions: auctions as List<AuctionModel>)),
    );
  }

  Future<void> _onRefreshAuctions(
    RefreshAuctions event,
    Emitter<AuctionListState> emit,
  ) async {
    final result = await repository.getAuctions();
    result.fold(
      (failure) => emit(AuctionListError(message: failure.message)),
      (auctions) =>
          emit(AuctionListLoaded(auctions: auctions as List<AuctionModel>)),
    );
  }
}

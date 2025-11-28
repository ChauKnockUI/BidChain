import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auction_repository.dart';
import 'auction_event.dart';
import 'auction_state.dart';

class AuctionBloc extends Bloc<AuctionEvent, AuctionState> {
  final AuctionRepository repository;

  AuctionBloc({required this.repository}) : super(AuctionInitial()) {
    on<GetAuctions>(_onGetAuctions);
    on<RefreshAuctions>(_onRefreshAuctions);
  }

  Future<void> _onGetAuctions(
    GetAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    emit(AuctionLoading());
    final result = await repository.getAuctions();
    result.fold(
      (failure) => emit(AuctionError(failure.message)),
      (auctions) => emit(AuctionLoaded(auctions)),
    );
  }

  Future<void> _onRefreshAuctions(
    RefreshAuctions event,
    Emitter<AuctionState> emit,
  ) async {
    // Keep current state or show loading overlay if needed
    // For now, we just reload
    final result = await repository.getAuctions();
    result.fold(
      (failure) => emit(AuctionError(failure.message)),
      (auctions) => emit(AuctionLoaded(auctions)),
    );
  }
}

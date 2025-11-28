import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/my_activity_repository.dart';
import 'my_activity_event.dart';
import 'my_activity_state.dart';

class MyActivityBloc extends Bloc<MyActivityEvent, MyActivityState> {
  final MyActivityRepository repository;

  MyActivityBloc({required this.repository})
    : super(const MyActivityInitial()) {
    on<LoadMyAuctions>(_onLoadMyAuctions);
    on<LoadMyBids>(_onLoadMyBids);
    on<RefreshMyActivity>(_onRefreshMyActivity);
  }

  Future<void> _onLoadMyAuctions(
    LoadMyAuctions event,
    Emitter<MyActivityState> emit,
  ) async {
    emit(const MyActivityLoading());

    final auctionsResult = await repository.getMyAuctions();
    final bidsResult = await repository.getMyBids();

    auctionsResult.fold(
      (failure) => emit(MyActivityError(message: failure.message)),
      (auctions) {
        bidsResult.fold(
          (failure) => emit(MyActivityError(message: failure.message)),
          (bids) => emit(MyActivityLoaded(auctions: auctions, bids: bids)),
        );
      },
    );
  }

  Future<void> _onLoadMyBids(
    LoadMyBids event,
    Emitter<MyActivityState> emit,
  ) async {
    emit(const MyActivityLoading());

    final auctionsResult = await repository.getMyAuctions();
    final bidsResult = await repository.getMyBids();

    auctionsResult.fold(
      (failure) => emit(MyActivityError(message: failure.message)),
      (auctions) {
        bidsResult.fold(
          (failure) => emit(MyActivityError(message: failure.message)),
          (bids) => emit(MyActivityLoaded(auctions: auctions, bids: bids)),
        );
      },
    );
  }

  Future<void> _onRefreshMyActivity(
    RefreshMyActivity event,
    Emitter<MyActivityState> emit,
  ) async {
    // Don't show loading state for refresh to avoid UI flicker
    final auctionsResult = await repository.getMyAuctions();
    final bidsResult = await repository.getMyBids();

    auctionsResult.fold(
      (failure) => emit(MyActivityError(message: failure.message)),
      (auctions) {
        bidsResult.fold(
          (failure) => emit(MyActivityError(message: failure.message)),
          (bids) => emit(MyActivityLoaded(auctions: auctions, bids: bids)),
        );
      },
    );
  }
}

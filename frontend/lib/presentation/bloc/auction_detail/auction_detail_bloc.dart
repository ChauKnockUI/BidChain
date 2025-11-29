import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auction_detail_repository.dart';
import 'auction_detail_event.dart';
import 'auction_detail_state.dart';

class AuctionDetailBloc extends Bloc<AuctionDetailEvent, AuctionDetailState> {
  final AuctionDetailRepository repository;

  AuctionDetailBloc({required this.repository})
    : super(const AuctionDetailInitial()) {
    on<LoadAuctionDetail>(_onLoadAuctionDetail);
    on<RefreshAuctionDetail>(_onRefreshAuctionDetail);
    on<PlaceBid>(_onPlaceBid);
  }

  Future<void> _onLoadAuctionDetail(
    LoadAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    emit(const AuctionDetailLoading());

    final result = await repository.getAuctionDetail(event.auctionId);

    result.fold(
      (failure) => emit(AuctionDetailError(message: failure.message)),
      (auction) => emit(AuctionDetailLoaded(auction: auction)),
    );
  }

  Future<void> _onRefreshAuctionDetail(
    RefreshAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await repository.getAuctionDetail(event.auctionId);

    result.fold(
      (failure) => emit(AuctionDetailError(message: failure.message)),
      (auction) => emit(AuctionDetailLoaded(auction: auction)),
    );
  }

  Future<void> _onPlaceBid(
    PlaceBid event,
    Emitter<AuctionDetailState> emit,
  ) async {
    // Get current auction from state
    if (state is! AuctionDetailLoaded) return;

    final currentAuction = (state as AuctionDetailLoaded).auction;
    emit(BidPlacing(auction: currentAuction));

    final result = await repository.placeBid(
      auctionId: event.auctionId,
      amountVnd: event.amountVnd,
    );

    await result.fold(
      (failure) async {
        emit(BidError(auction: currentAuction, message: failure.message));
        // Return to loaded state after showing error
        await Future.delayed(const Duration(milliseconds: 100));
        emit(AuctionDetailLoaded(auction: currentAuction));
      },
      (_) async {
        // Bid successful, refresh auction data
        final refreshResult = await repository.getAuctionDetail(
          event.auctionId,
        );

        refreshResult.fold(
          (failure) => emit(AuctionDetailError(message: failure.message)),
          (updatedAuction) {
            emit(
              BidPlaced(
                auction: updatedAuction,
                message: 'Đặt giá thành công!',
              ),
            );
            // Return to loaded state after showing success
            Future.delayed(const Duration(seconds: 2), () {
              if (!emit.isDone) {
                emit(AuctionDetailLoaded(auction: updatedAuction));
              }
            });
          },
        );
      },
    );
  }
}

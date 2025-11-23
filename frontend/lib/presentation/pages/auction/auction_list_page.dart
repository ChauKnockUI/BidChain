import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/auction/auction_card.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({Key? key}) : super(key: key);

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Active Auctions',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.black, // Đảm bảo màu icon hiển thị rõ trên nền trắng
          onPressed: () async {
            // --- SỬA LỖI TẠI ĐÂY ---
            // Sử dụng maybePop để an toàn hơn, tránh lỗi _debugLocked
            final canPop = await Navigator.of(context).maybePop();
            if (!canPop) {
              // Nếu không thể pop (ví dụ: đang ở trang chủ), bạn có thể xử lý khác
              // hoặc để trống.
              print("Không thể quay lại trang trước");
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Auctions',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Replace with actual data
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: AuctionCard(
                    auctionId: '1',
                    title: 'Sample Auction',
                    currentBid: '1.5 ETH',
                    endTime: 'in 2 hours',
                    bidCount: 5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
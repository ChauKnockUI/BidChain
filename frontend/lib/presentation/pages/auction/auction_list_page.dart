import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../data/models/auction_model.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/auction/auction_card.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  @override
  Widget build(BuildContext context) {
    // Check if we're in a route that can be popped (standalone page)
    final canNavigateBack = ModalRoute.of(context)?.canPop ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Auctions',
          style: AppTextStyles.h3,
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.black),
        automaticallyImplyLeading: false, // Disable default back button
        leading: canNavigateBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: AppColors.black,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              )
            : null, // No back button when inside MainLayout
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available Auctions', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                final auction = AuctionModel(
                  id: 'auction_${index + 1}',
                  title: 'Sample Auction ${index + 1}',
                  description: 'Description for auction ${index + 1}',
                  images: [],
                  status: 'ACTIVE',
                  startPriceVnd: 1000000.0 * (index + 1),
                  currentPriceVnd: 1500000.0 * (index + 1),
                  stepPriceVnd: 100000.0,
                  endTime: DateTime.now().add(Duration(hours: 2 + index)),
                  seller: UserEntity(
                    id: 'seller_${index + 1}',
                    username: 'seller${index + 1}',
                    email: 'seller${index + 1}@example.com',
                    fullName: 'Seller ${index + 1}',
                    role: 'USER',
                    walletAddress: '0x123...',
                    createdAt: DateTime.now(),
                  ),
                  createdAt: DateTime.now(),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AuctionCard(auction: auction),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

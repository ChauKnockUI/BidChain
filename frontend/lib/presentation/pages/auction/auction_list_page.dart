import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../bloc/auction/auction_bloc.dart';
import '../../bloc/auction/auction_event.dart';
import '../../bloc/auction/auction_state.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../widgets/auction/auction_card.dart';
import '../../widgets/common/category_chip.dart';

class AuctionListPage extends StatefulWidget {
  const AuctionListPage({super.key});

  @override
  State<AuctionListPage> createState() => _AuctionListPageState();
}

class _AuctionListPageState extends State<AuctionListPage> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AuctionBloc>().add(RefreshAuctions());
          context.read<CategoryBloc>().add(GetCategories());
        },
        color: AppColors.black,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
              // Search Bar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildSearchBar(),
                ),
              ),

              // Category Section
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Categories',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Auction Grid
              BlocBuilder<AuctionBloc, AuctionState>(
                builder: (context, state) {
                  if (state is AuctionLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuctionError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.black,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<AuctionBloc>().add(
                                      RefreshAuctions(),
                                    );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AuctionLoaded) {
                    // Filter auctions by selected category and search query
                    var filteredAuctions = state.auctions;

                    // Filter by category
                    if (_selectedCategoryId != null) {
                      filteredAuctions = filteredAuctions
                          .where((auction) =>
                              auction.categoryId == _selectedCategoryId)
                          .toList();
                    }

                    // Filter by search query
                    if (_searchQuery.isNotEmpty) {
                      filteredAuctions = filteredAuctions.where((auction) {
                        final titleLower = auction.title.toLowerCase();
                        final descLower = auction.description.toLowerCase();
                        return titleLower.contains(_searchQuery) ||
                            descLower.contains(_searchQuery);
                      }).toList();
                    }

                    if (filteredAuctions.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: AppColors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No auctions found for "$_searchQuery"'
                                    : _selectedCategoryId != null
                                        ? 'No auctions found in this category'
                                        : 'No active auctions found',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final auction = filteredAuctions[index];
                              return AuctionCard(
                                auctionId: auction.auctionId,
                                title: auction.title,
                                imageUrl: auction.images.isNotEmpty
                                    ? auction.images.first
                                    : null,
                                currentBid: auction.formattedCurrentPrice,
                                timeLeft: _calculateTimeLeft(auction.endTime),
                                bidCount: auction.bidCount,
                                sellerName: auction.sellerName,
                                onTap: () {
                                  context.go(
                                    '${AppRoutes.auctionDetail}/${auction.auctionId}',
                                  );
                                },
                              );
                            },
                            childCount: filteredAuctions.length,
                          ),
                        ),
                      );
                    }
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'All Auctions',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.black,
          size: 20,
        ),
        onPressed: () => context.go(AppRoutes.home),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search auctions...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
          prefixIcon: const Icon(Icons.search, color: AppColors.black),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          // Add "All" category at the beginning
          final allCategories = [
            {'id': null, 'name': 'All', 'icon': Icons.apps},
            ...state.categories.map(
              (cat) => {
                'id': cat.id,
                'name': cat.name,
                'icon': _getCategoryIcon(cat.name),
              },
            ),
          ];

          return SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = _selectedCategoryId == category['id'];

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < allCategories.length - 1 ? 8 : 0,
                  ),
                  child: CategoryChip(
                    label: category['name'] as String,
                    icon: category['icon'] as IconData?,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category['id'] as String?;
                      });
                    },
                  ),
                );
              },
            ),
          );
        } else if (state is CategoryLoading) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else {
          // Show default categories if loading fails
          return SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CategoryChip(
                  label: 'All',
                  icon: Icons.apps,
                  isSelected: _selectedCategoryId == null,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('điện tử') ||
        name.contains('điện thoại') ||
        name.contains('laptop')) {
      return Icons.devices;
    } else if (name.contains('thời trang') ||
        name.contains('quần áo') ||
        name.contains('giày')) {
      return Icons.checkroom;
    } else if (name.contains('nghệ thuật') ||
        name.contains('tranh') ||
        name.contains('tác phẩm')) {
      return Icons.palette;
    } else if (name.contains('đồ cổ') || name.contains('sưu tầm')) {
      return Icons.stars;
    } else if (name.contains('xe') ||
        name.contains('phương tiện') ||
        name.contains('ô tô') ||
        name.contains('xe máy')) {
      return Icons.directions_car;
    } else if (name.contains('thủ công') ||
        name.contains('mỹ nghệ') ||
        name.contains('handmade') ||
        name.contains('gốm')) {
      return Icons.handyman;
    } else if (name.contains('sách') || name.contains('book')) {
      return Icons.book;
    } else if (name.contains('khác')) {
      return Icons.category;
    }

    return Icons.category; // default
  }

  String _calculateTimeLeft(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Ended';
    }

    if (difference.inDays > 0) {
      final hours = difference.inHours % 24;
      return '${difference.inDays}d ${hours}h';
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours}h ${minutes}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}

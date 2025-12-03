import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/notification_popup_service.dart';
import 'package:frontend/core/services/socket_service.dart';
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
import '../../bloc/notification/notification_bloc.dart';
import 'dart:async';

import '../../widgets/auction/auction_card.dart';

import '../../widgets/common/category_chip.dart';
import '../../widgets/common/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Smart refresh mechanism
  DateTime? _lastRefreshTime;
  static const _refreshThreshold = Duration(minutes: 5);
  StreamSubscription? _notificationSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastRefreshTime = DateTime.now();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });

    final socketService = SocketService();
    _notificationSubscription = socketService.notificationStream.listen((data) {
      if (mounted) {
        NotificationPopupService.show(
          context: context,
          title: data['title'] ?? 'Thông báo mới',
          message: data['message'] ?? '',
          onTap: () {
            // Navigate to notifications page
            Navigator.pushNamed(context, '/notifications');
          },
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  /// Monitor app lifecycle to refresh data when needed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshIfNeeded();
    }
  }

  /// Smart refresh: only refresh if more than 5 minutes have passed
  void _refreshIfNeeded() {
    final now = DateTime.now();
    if (_lastRefreshTime == null ||
        now.difference(_lastRefreshTime!) > _refreshThreshold) {
      // Refresh data silently in background
      context.read<AuctionBloc>().add(RefreshAuctions());
      context.read<CategoryBloc>().add(GetCategories());
      _lastRefreshTime = now;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AuctionBloc>().add(RefreshAuctions());
          context.read<CategoryBloc>().add(GetCategories());
          _lastRefreshTime = DateTime.now(); // Update refresh time
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

            // Popular Auctions Section
            BlocBuilder<AuctionBloc, AuctionState>(
              builder: (context, state) {
                if (state is AuctionLoaded && state.auctions.isNotEmpty) {
                  // Filter auctions by selected category and search query
                  var filteredAuctions = state.auctions;

                  // Filter by category
                  if (_selectedCategoryId != null) {
                    filteredAuctions = filteredAuctions
                        .where(
                          (auction) =>
                              auction.categoryId == _selectedCategoryId,
                        )
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

                  final popularAuctions = [...filteredAuctions]
                    ..sort((a, b) => b.bidCount.compareTo(a.bidCount));
                  final topAuctions = popularAuctions.take(10).toList();

                  if (topAuctions.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  return SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SectionHeader(
                            title: 'Popular Auctions',
                            onSeeAllTap: () =>
                                context.go(AppRoutes.auctionList),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 310,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: topAuctions.length,
                            itemBuilder: (context, index) {
                              final auction = topAuctions[index];
                              return Container(
                                width: 180,
                                margin: EdgeInsets.only(
                                  right: index < topAuctions.length - 1
                                      ? 12
                                      : 0,
                                ),
                                child: AuctionCard(
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
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Active Auctions Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Active Auctions',
                  onSeeAllTap: () => context.go(AppRoutes.auctionList),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

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
                          Text(state.message, style: AppTextStyles.bodyMedium),
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
                        .where(
                          (auction) =>
                              auction.categoryId == _selectedCategoryId,
                        )
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
                              _selectedCategoryId != null
                                  ? 'No auctions found in this category'
                                  : 'No active auctions found',
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
                              childAspectRatio: 0.57,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
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
                        }, childCount: filteredAuctions.length),
                      ),
                    );
                  }
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'BidChain',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        // Notification Icon with Badge
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return IconButton(
              icon: Badge(
                 backgroundColor: Colors.red,
                isLabelVisible: state.unreadCount > 0,
                label: Text('${state.unreadCount}'),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.black,
                ),
              ),
              onPressed: () {
                context.push('/notifications');
              },
            );
          },
        ),
      ],
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

import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../pages/home/home_page.dart';
import '../pages/auction/auction_list_page.dart';
import '../pages/wallet/wallet_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/create_auction/create_auction_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AuctionListPage(),
    const SizedBox.shrink(), // Placeholder for center button
    const WalletPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // Center button - Navigate to Create Auction
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateAuctionScreen()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.accentDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabTapped(2),
          borderRadius: BorderRadius.circular(32),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipPath(
      clipper: BottomNavClipper(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 79,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.gavel_rounded,
                  label: 'Auctions',
                  index: 1,
                ),
                const SizedBox(width: 64), // Space for floating button
                _buildNavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? AppColors.accent : AppColors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for smooth curved notch at the top
class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    final notchRadius = 32.0; // Radius of the circular notch
    final notchMargin = 8.0; // Space around the button
    final centerX = size.width / 2;
    
    // Start from top left
    path.moveTo(0, 0);
    
    // Draw to the start of the curve
    path.lineTo(centerX - notchRadius - notchMargin, 0);
    
    // Create smooth U-shaped curve going DOWN
    path.arcToPoint(
      Offset(centerX + notchRadius + notchMargin, 0),
      radius: Radius.circular(notchRadius + notchMargin),
      clockwise: false, // This makes it curve downward (U-shape)
    );
    
    // Draw to top right
    path.lineTo(size.width, 0);
    
    // Draw right side
    path.lineTo(size.width, size.height);
    
    // Draw bottom
    path.lineTo(0, size.height);
    
    // Close path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

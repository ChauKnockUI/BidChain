// import 'package:flutter/material.dart';
// import '../../config/theme/app_colors.dart';
// import '../../config/theme/app_text_styles.dart';
// import '../../presentation/widgets/auction/auction_card.dart';
// import '../../presentation/widgets/states/empty_state.dart';
// import '../../presentation/widgets/states/error_view.dart';
// import '../../presentation/widgets/user/user_avatar.dart';
// import '../../presentation/widgets/common/primary_button.dart';
// import '../../presentation/widgets/common/secondary_button.dart';
// import '../../presentation/widgets/common/form_input.dart';
// import '../../presentation/widgets/common/search_input.dart';
// import '../../presentation/widgets/common/bid_dialog.dart';
// import '../../presentation/widgets/common/confirm_dialog.dart';
// import '../../presentation/widgets/common/loading_indicator.dart';
// import '../../presentation/widgets/common/full_screen_loading.dart';
// import '../../presentation/widgets/common/custom_toast.dart';
// import '../../data/models/auction_model.dart';
// import '../../domain/entities/user_entity.dart';

// class ComponentShowcasePage extends StatefulWidget {
//   const ComponentShowcasePage({super.key});

//   @override
//   State<ComponentShowcasePage> createState() => _ComponentShowcasePageState();
// }

// class _ComponentShowcasePageState extends State<ComponentShowcasePage> {
//   int _currentTab = 0;

//   // Form Input States
//   String _email = '';
//   String _password = '';
//   String _fullName = '';
//   String _phoneNumber = '';
//   String _description = '';
//   String _emailError = '';
//   String _passwordError = '';

//   // Search Input States
//   String _searchQuery = '';
//   List<String> _searchResults = [];

//   // Dialog States
//   bool _showBidDialog = false;
//   bool _showConfirmDialog = false;
//   bool _showWarningDialog = false;
//   bool _showDangerDialog = false;
//   bool _showSuccessDialog = false;
//   double _currentBidAmount = 10.5;

//   // Loading States
//   bool _showFullScreenLoading = false;
//   bool _showDarkLoading = false;
//   bool _isLoadingData = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBar(title: const Text('Component Showcase'), elevation: 0),
//       body: IndexedStack(
//         index: _currentTab,
//         children: [
//           _buildPrimaryButtonTab(),
//           _buildFormInputTab(),
//           _buildDialogsTab(),
//           _buildLoadingTab(),
//           _buildUserAvatarTab(),
//           _buildAuctionCardTab(),
//           _buildEmptyStateTab(),
//           _buildErrorViewTab(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentTab,
//         onTap: (index) {
//           setState(() {
//             _currentTab = index;
//           });
//         },
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.black54,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.smart_button),
//             label: 'Button',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.input), label: 'Form Input'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat_bubble_outline),
//             label: 'Dialogs',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.hourglass_empty),
//             label: 'Loading',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Avatar'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.card_giftcard),
//             label: 'Auction Card',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.inbox),
//             label: 'Empty State',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.error_outline),
//             label: 'Error View',
//           ),
//         ],
//       ),
//     );
//   }

//   // PrimaryButton Demo Tab
//   Widget _buildPrimaryButtonTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('PrimaryButton - Trạng thái cơ bản'),
//           const SizedBox(height: 20),

//           // Normal Button
//           PrimaryButton(
//             title: 'Đấu giá ngay',
//             onPress: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Button được nhấn!')),
//               );
//             },
//           ),
//           const SizedBox(height: 16),

//           // Button with Icon
//           PrimaryButton(
//             title: 'Thêm vào giỏ',
//             icon: Icons.shopping_cart_outlined,
//             onPress: () {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ!')));
//             },
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('PrimaryButton - Trạng thái Loading'),
//           const SizedBox(height: 20),

//           PrimaryButton(title: 'Đang xử lý...', loading: true, onPress: () {}),
//           const SizedBox(height: 40),

//           _buildSectionTitle('PrimaryButton - Trạng thái Disabled'),
//           const SizedBox(height: 20),

//           const PrimaryButton(title: 'Nút không khả dụng', disabled: true),
//           const SizedBox(height: 16),

//           const PrimaryButton(
//             title: 'Đã đấu giá',
//             icon: Icons.check_circle_outline,
//             disabled: true,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('PrimaryButton - Kích thước tùy chỉnh'),
//           const SizedBox(height: 20),

//           // Full width button
//           PrimaryButton(
//             title: 'Nút chiều rộng đầy đủ',
//             width: double.infinity,
//             onPress: () {},
//           ),
//           const SizedBox(height: 16),

//           // Custom width button
//           Center(
//             child: PrimaryButton(
//               title: 'Nút nhỏ',
//               width: 150,
//               height: 44,
//               onPress: () {},
//             ),
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('PrimaryButton - Các ví dụ thực tế'),
//           const SizedBox(height: 20),

//           PrimaryButton(
//             title: 'Đăng nhập',
//             icon: Icons.login,
//             width: double.infinity,
//             onPress: () {},
//           ),
//           const SizedBox(height: 12),

//           PrimaryButton(
//             title: 'Tạo cuộc đấu giá mới',
//             icon: Icons.add_circle_outline,
//             width: double.infinity,
//             onPress: () {},
//           ),
//           const SizedBox(height: 12),

//           PrimaryButton(
//             title: 'Xác nhận thanh toán',
//             icon: Icons.payment,
//             width: double.infinity,
//             onPress: () {},
//           ),
//           const SizedBox(height: 12),

//           PrimaryButton(
//             title: 'Kết nối ví',
//             icon: Icons.account_balance_wallet,
//             width: double.infinity,
//             onPress: () {},
//           ),
//           const SizedBox(height: 60),

//           // SecondaryButton Section
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionTitle('SecondaryButton - Trạng thái cơ bản'),
//                 const SizedBox(height: 20),

//                 // Normal Button
//                 SecondaryButton(
//                   title: 'Xem chi tiết',
//                   onPress: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Secondary Button được nhấn!'),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // Button with Icon
//                 SecondaryButton(
//                   title: 'Lọc kết quả',
//                   icon: Icons.filter_list,
//                   onPress: () {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(const SnackBar(content: Text('Mở bộ lọc!')));
//                   },
//                 ),
//                 const SizedBox(height: 40),

//                 _buildSectionTitle('SecondaryButton - Trạng thái Loading'),
//                 const SizedBox(height: 20),

//                 SecondaryButton(
//                   title: 'Đang tải...',
//                   loading: true,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 40),

//                 _buildSectionTitle('SecondaryButton - Trạng thái Disabled'),
//                 const SizedBox(height: 20),

//                 const SecondaryButton(title: 'Không khả dụng', disabled: true),
//                 const SizedBox(height: 16),

//                 const SecondaryButton(
//                   title: 'Đã hoàn thành',
//                   icon: Icons.check,
//                   disabled: true,
//                 ),
//                 const SizedBox(height: 40),

//                 _buildSectionTitle('SecondaryButton - Kích thước tùy chỉnh'),
//                 const SizedBox(height: 20),

//                 // Full width button
//                 SecondaryButton(
//                   title: 'Chiều rộng đầy đủ',
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 16),

//                 // Custom width button
//                 Center(
//                   child: SecondaryButton(
//                     title: 'Nhỏ',
//                     width: 120,
//                     height: 44,
//                     onPress: () {},
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 _buildSectionTitle('SecondaryButton - Các ví dụ thực tế'),
//                 const SizedBox(height: 20),

//                 SecondaryButton(
//                   title: 'Hủy bỏ',
//                   icon: Icons.close,
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 12),

//                 SecondaryButton(
//                   title: 'Xem lịch sử',
//                   icon: Icons.history,
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 12),

//                 SecondaryButton(
//                   title: 'Chia sẻ',
//                   icon: Icons.share,
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 12),

//                 SecondaryButton(
//                   title: 'Tải xuống',
//                   icon: Icons.download,
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//                 const SizedBox(height: 40),

//                 _buildSectionTitle('So sánh Primary vs Secondary'),
//                 const SizedBox(height: 20),

//                 Row(
//                   children: [
//                     Expanded(
//                       child: PrimaryButton(title: 'Xác nhận', onPress: () {}),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: SecondaryButton(title: 'Hủy', onPress: () {}),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // FormInput Demo Tab
//   Widget _buildFormInputTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('FormInput - Input cơ bản'),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Email',
//             value: _email,
//             onChangeText: (value) {
//               setState(() {
//                 _email = value;
//                 _emailError = '';
//               });
//             },
//             hint: 'Nhập địa chỉ email của bạn',
//             keyboardType: TextInputType.emailAddress,
//             prefixIcon: Icons.email_outlined,
//           ),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Họ và tên',
//             value: _fullName,
//             onChangeText: (value) {
//               setState(() {
//                 _fullName = value;
//               });
//             },
//             hint: 'Nhập họ và tên đầy đủ',
//             prefixIcon: Icons.person_outline,
//           ),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Số điện thoại',
//             value: _phoneNumber,
//             onChangeText: (value) {
//               setState(() {
//                 _phoneNumber = value;
//               });
//             },
//             hint: '+84 xxx xxx xxx',
//             keyboardType: TextInputType.phone,
//             prefixIcon: Icons.phone_outlined,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('FormInput - Password Field'),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Mật khẩu',
//             value: _password,
//             onChangeText: (value) {
//               setState(() {
//                 _password = value;
//                 _passwordError = '';
//               });
//             },
//             hint: 'Nhập mật khẩu của bạn',
//             secureText: true,
//             prefixIcon: Icons.lock_outline,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('FormInput - Với Error Message'),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Email',
//             value: _email,
//             onChangeText: (value) {
//               setState(() {
//                 _email = value;
//                 // Validate email
//                 if (value.isEmpty) {
//                   _emailError = 'Email không được để trống';
//                 } else if (!value.contains('@')) {
//                   _emailError = 'Email không đúng định dạng';
//                 } else {
//                   _emailError = '';
//                 }
//               });
//             },
//             error: _emailError,
//             hint: 'example@email.com',
//             keyboardType: TextInputType.emailAddress,
//             prefixIcon: Icons.email_outlined,
//           ),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Mật khẩu',
//             value: _password,
//             onChangeText: (value) {
//               setState(() {
//                 _password = value;
//                 // Validate password
//                 if (value.isEmpty) {
//                   _passwordError = 'Mật khẩu không được để trống';
//                 } else if (value.length < 6) {
//                   _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
//                 } else {
//                   _passwordError = '';
//                 }
//               });
//             },
//             error: _passwordError,
//             hint: 'Ít nhất 6 ký tự',
//             secureText: true,
//             prefixIcon: Icons.lock_outline,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('FormInput - Multiline (Description)'),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Mô tả sản phẩm',
//             value: _description,
//             onChangeText: (value) {
//               setState(() {
//                 _description = value;
//               });
//             },
//             hint: 'Nhập mô tả chi tiết về sản phẩm đấu giá...',
//             maxLines: 5,
//             prefixIcon: Icons.description_outlined,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('FormInput - Disabled State'),
//           const SizedBox(height: 20),

//           FormInput(
//             label: 'Tên người dùng',
//             value: 'ChauKnockUI',
//             onChangeText: (_) {},
//             enabled: false,
//             prefixIcon: Icons.account_circle_outlined,
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('Form đăng nhập mẫu'),
//           const SizedBox(height: 20),

//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.grey.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   'Đăng nhập',
//                   style: AppTextStyles.h3.copyWith(color: AppColors.accent),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 FormInput(
//                   label: 'Email',
//                   value: _email,
//                   onChangeText: (value) {
//                     setState(() {
//                       _email = value;
//                       _emailError = '';
//                     });
//                   },
//                   error: _emailError,
//                   hint: 'example@email.com',
//                   keyboardType: TextInputType.emailAddress,
//                   prefixIcon: Icons.email_outlined,
//                 ),
//                 const SizedBox(height: 20),
//                 FormInput(
//                   label: 'Mật khẩu',
//                   value: _password,
//                   onChangeText: (value) {
//                     setState(() {
//                       _password = value;
//                       _passwordError = '';
//                     });
//                   },
//                   error: _passwordError,
//                   hint: 'Nhập mật khẩu',
//                   secureText: true,
//                   prefixIcon: Icons.lock_outline,
//                 ),
//                 const SizedBox(height: 24),
//                 PrimaryButton(
//                   title: 'Đăng nhập',
//                   width: double.infinity,
//                   onPress: () {
//                     // Validate
//                     setState(() {
//                       if (_email.isEmpty) {
//                         _emailError = 'Email không được để trống';
//                       }
//                       if (_password.isEmpty) {
//                         _passwordError = 'Mật khẩu không được để trống';
//                       }

//                       if (_emailError.isEmpty && _passwordError.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Đăng nhập thành công!'),
//                           ),
//                         );
//                       }
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 SecondaryButton(
//                   title: 'Đăng ký tài khoản',
//                   width: double.infinity,
//                   onPress: () {},
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 60),

//           // SearchInput Section
//           _buildSectionTitle('SearchInput - Tìm kiếm'),
//           const SizedBox(height: 20),

//           SearchInput(
//             placeholder: 'Tìm kiếm cuộc đấu giá...',
//             onChangeText: (value) {
//               setState(() {
//                 _searchQuery = value;
//                 // Simulate search results
//                 if (value.isNotEmpty) {
//                   _searchResults =
//                       [
//                             'Đấu giá điện thoại iPhone 15',
//                             'Đấu giá laptop Dell XPS',
//                             'Đấu giá đồng hồ Rolex',
//                             'Đấu giá tranh nghệ thuật',
//                           ]
//                           .where(
//                             (item) => item.toLowerCase().contains(
//                               value.toLowerCase(),
//                             ),
//                           )
//                           .toList();
//                 } else {
//                   _searchResults = [];
//                 }
//               });
//             },
//           ),

//           if (_searchQuery.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.grey.withOpacity(0.3)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Kết quả tìm kiếm: "$_searchQuery"',
//                     style: AppTextStyles.labelLarge.copyWith(
//                       color: AppColors.accent,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (_searchResults.isEmpty)
//                     Text(
//                       'Không tìm thấy kết quả nào',
//                       style: AppTextStyles.bodySmall.copyWith(
//                         color: AppColors.grey,
//                       ),
//                     )
//                   else
//                     ..._searchResults.map(
//                       (result) => Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: Row(
//                           children: [
//                             Icon(Icons.search, size: 16, color: AppColors.grey),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 result,
//                                 style: AppTextStyles.bodyMedium,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//           const SizedBox(height: 40),

//           _buildSectionTitle('SearchInput - Các ví dụ khác'),
//           const SizedBox(height: 20),

//           SearchInput(
//             placeholder: 'Tìm người dùng...',
//             onChangeText: (value) {
//               // Search users
//             },
//           ),
//           const SizedBox(height: 16),

//           SearchInput(
//             placeholder: 'Tìm theo danh mục',
//             onChangeText: (value) {
//               // Search categories
//             },
//           ),
//           const SizedBox(height: 16),

//           SearchInput(
//             placeholder: 'Tìm theo vị trí',
//             onChangeText: (value) {
//               // Search locations
//             },
//           ),
//           const SizedBox(height: 40),

//           _buildSectionTitle('SearchInput - Trong thanh tìm kiếm'),
//           const SizedBox(height: 20),

//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 SearchInput(
//                   placeholder: 'Tìm kiếm tất cả...',
//                   onChangeText: (value) {
//                     // Global search
//                   },
//                   onSearch: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Thực hiện tìm kiếm...')),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _buildSearchChip('Điện thoại'),
//                     _buildSearchChip('Laptop'),
//                     _buildSearchChip('Đồng hồ'),
//                     _buildSearchChip('Xe máy'),
//                     _buildSearchChip('Bất động sản'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchChip(String label) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _searchQuery = label;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: AppColors.secondary.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.accent.withOpacity(0.3)),
//         ),
//         child: Text(
//           label,
//           style: AppTextStyles.bodySmall.copyWith(
//             color: AppColors.accent,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   // Dialogs Demo Tab
//   Widget _buildDialogsTab() {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle('BidDialog - Modal đấu giá'),
//               const SizedBox(height: 20),

//               Text(
//                 'BidDialog là modal chuyên dụng cho việc nhập giá đấu với validation và quick bid buttons.',
//                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
//               ),
//               const SizedBox(height: 20),

//               PrimaryButton(
//                 title: 'Mở BidDialog',
//                 icon: Icons.gavel,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showBidDialog = true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryLight,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.secondary.withOpacity(0.5),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Tính năng BidDialog:',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildFeatureItem('✓ Hiển thị giá hiện tại'),
//                     _buildFeatureItem('✓ Validation giá tối thiểu'),
//                     _buildFeatureItem(
//                       '✓ Quick bid buttons (+0.1, +0.5, +1, +5 ETH)',
//                     ),
//                     _buildFeatureItem('✓ Format số tiền tự động'),
//                     _buildFeatureItem('✓ Loading state khi confirm'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('ConfirmDialog - Modal xác nhận'),
//               const SizedBox(height: 20),

//               Text(
//                 'ConfirmDialog dùng cho các hành động cần xác nhận từ người dùng với nhiều loại khác nhau.',
//                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
//               ),
//               const SizedBox(height: 20),

//               // Info Dialog
//               PrimaryButton(
//                 title: 'Info Dialog',
//                 icon: Icons.info_outline,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showConfirmDialog = true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Warning Dialog
//               PrimaryButton(
//                 title: 'Warning Dialog',
//                 icon: Icons.warning_amber_rounded,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showWarningDialog = true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Danger Dialog
//               PrimaryButton(
//                 title: 'Danger Dialog',
//                 icon: Icons.error_outline,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showDangerDialog = true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Success Dialog
//               PrimaryButton(
//                 title: 'Success Dialog',
//                 icon: Icons.check_circle_outline,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showSuccessDialog = true;
//                   });
//                 },
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Use Cases - Các trường hợp sử dụng'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'BidDialog:',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.accent,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildUseCaseItem('• Đặt giá đấu trong cuộc đấu giá'),
//                     _buildUseCaseItem('• Mua ngay với giá cố định'),
//                     _buildUseCaseItem('• Đặt giá tối đa (auto bid)'),
//                     const SizedBox(height: 16),
//                     Text(
//                       'ConfirmDialog:',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.accent,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildUseCaseItem('• Xác nhận xóa cuộc đấu giá'),
//                     _buildUseCaseItem('• Xác nhận hủy giao dịch'),
//                     _buildUseCaseItem('• Xác nhận rút khỏi cuộc đấu giá'),
//                     _buildUseCaseItem('• Thông báo hoàn thành hành động'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // BidDialog Overlay
//         BidDialog(
//           visible: _showBidDialog,
//           onClose: () {
//             setState(() {
//               _showBidDialog = false;
//             });
//           },
//           onConfirm: (bidAmount) {
//             setState(() {
//               _currentBidAmount = bidAmount;
//               _showBidDialog = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Đã đặt giá: $bidAmount ETH'),
//                 backgroundColor: AppColors.success,
//               ),
//             );
//           },
//           currentBid: _currentBidAmount,
//           minimumBid: _currentBidAmount + 0.1,
//           defaultValue: _currentBidAmount + 1,
//           title: 'Đặt giá đấu',
//           description: 'Nhập số tiền bạn muốn đấu giá',
//         ),

//         // Info ConfirmDialog
//         ConfirmDialog(
//           visible: _showConfirmDialog,
//           onClose: () {
//             setState(() {
//               _showConfirmDialog = false;
//             });
//           },
//           onConfirm: () {
//             setState(() {
//               _showConfirmDialog = false;
//             });
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(const SnackBar(content: Text('Đã xác nhận!')));
//           },
//           type: ConfirmDialogType.info,
//           title: 'Thông báo',
//           message:
//               'Đây là một thông báo thông tin. Bạn có muốn tiếp tục không?',
//           confirmText: 'Đồng ý',
//           cancelText: 'Hủy',
//         ),

//         // Warning ConfirmDialog
//         ConfirmDialog(
//           visible: _showWarningDialog,
//           onClose: () {
//             setState(() {
//               _showWarningDialog = false;
//             });
//           },
//           onConfirm: () {
//             setState(() {
//               _showWarningDialog = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Đã xác nhận cảnh báo!'),
//                 backgroundColor: AppColors.warning,
//               ),
//             );
//           },
//           type: ConfirmDialogType.warning,
//           title: 'Cảnh báo',
//           message:
//               'Hành động này có thể ảnh hưởng đến dữ liệu của bạn. Bạn có chắc chắn muốn tiếp tục?',
//           confirmText: 'Tiếp tục',
//           cancelText: 'Hủy bỏ',
//         ),

//         // Danger ConfirmDialog
//         ConfirmDialog(
//           visible: _showDangerDialog,
//           onClose: () {
//             setState(() {
//               _showDangerDialog = false;
//             });
//           },
//           onConfirm: () {
//             setState(() {
//               _showDangerDialog = false;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Đã xóa!'),
//                 backgroundColor: AppColors.error,
//               ),
//             );
//           },
//           type: ConfirmDialogType.danger,
//           title: 'Xác nhận xóa',
//           message:
//               'Bạn có chắc chắn muốn xóa cuộc đấu giá này? Hành động này không thể hoàn tác.',
//           confirmText: 'Xóa',
//           cancelText: 'Không',
//         ),

//         // Success ConfirmDialog
//         ConfirmDialog(
//           visible: _showSuccessDialog,
//           onClose: () {
//             setState(() {
//               _showSuccessDialog = false;
//             });
//           },
//           onConfirm: () {
//             setState(() {
//               _showSuccessDialog = false;
//             });
//           },
//           type: ConfirmDialogType.success,
//           title: 'Thành công!',
//           message: 'Giao dịch của bạn đã được xử lý thành công.',
//           confirmText: 'Đóng',
//           cancelText: 'Xem chi tiết',
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(
//         text,
//         style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
//       ),
//     );
//   }

//   Widget _buildUseCaseItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Text(
//         text,
//         style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey),
//       ),
//     );
//   }

//   // Loading Demo Tab
//   Widget _buildLoadingTab() {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle('LoadingIndicator - Loading nhỏ'),
//               const SizedBox(height: 20),

//               Text(
//                 'LoadingIndicator là component loading nhỏ, có thể nhúng vào bất kỳ đâu trong UI.',
//                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
//               ),
//               const SizedBox(height: 20),

//               // Default LoadingIndicator
//               Container(
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.grey.withOpacity(0.3)),
//                 ),
//                 child: const LoadingIndicator(),
//               ),
//               const SizedBox(height: 20),

//               // LoadingIndicator with message
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.grey.withOpacity(0.3)),
//                 ),
//                 child: const LoadingIndicator(message: 'Đang tải dữ liệu...'),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('LoadingIndicator - Kích thước khác nhau'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       children: [
//                         const LoadingIndicator(size: 24, strokeWidth: 2),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Small',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const LoadingIndicator(size: 40, strokeWidth: 3),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Medium',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const LoadingIndicator(size: 60, strokeWidth: 4),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Large',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('LoadingIndicator - Màu sắc khác nhau'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       children: [
//                         LoadingIndicator(size: 40, color: AppColors.accent),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Accent',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         LoadingIndicator(size: 40, color: AppColors.success),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Success',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         LoadingIndicator(size: 40, color: AppColors.error),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Error',
//                           style: AppTextStyles.bodySmall.copyWith(
//                             color: AppColors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('FullScreenLoading - Loading toàn màn hình'),
//               const SizedBox(height: 20),

//               Text(
//                 'FullScreenLoading tạo overlay loading toàn màn hình, chặn tương tác trong khi xử lý.',
//                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
//               ),
//               const SizedBox(height: 20),

//               // Light FullScreenLoading
//               PrimaryButton(
//                 title: 'Hiển thị Light Loading',
//                 icon: Icons.hourglass_empty,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showFullScreenLoading = true;
//                   });
//                   // Auto hide after 3 seconds
//                   Future.delayed(const Duration(seconds: 3), () {
//                     if (mounted) {
//                       setState(() {
//                         _showFullScreenLoading = false;
//                       });
//                     }
//                   });
//                 },
//               ),
//               const SizedBox(height: 12),

//               // Dark FullScreenLoading
//               PrimaryButton(
//                 title: 'Hiển thị Dark Loading',
//                 icon: Icons.hourglass_full,
//                 width: double.infinity,
//                 onPress: () {
//                   setState(() {
//                     _showDarkLoading = true;
//                   });
//                   // Auto hide after 3 seconds
//                   Future.delayed(const Duration(seconds: 3), () {
//                     if (mounted) {
//                       setState(() {
//                         _showDarkLoading = false;
//                       });
//                     }
//                   });
//                 },
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Use Cases - Simulate loading data'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Tải danh sách đấu giá',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     if (_isLoadingData)
//                       const LoadingIndicator(message: 'Đang tải danh sách...')
//                     else ...[
//                       Text(
//                         'Danh sách đã tải xong!',
//                         style: AppTextStyles.bodyMedium.copyWith(
//                           color: AppColors.success,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       SecondaryButton(
//                         title: 'Tải lại',
//                         onPress: () {
//                           setState(() {
//                             _isLoadingData = true;
//                           });
//                           Future.delayed(const Duration(seconds: 2), () {
//                             if (mounted) {
//                               setState(() {
//                                 _isLoadingData = false;
//                               });
//                             }
//                           });
//                         },
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Tính năng'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryLight,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.secondary.withOpacity(0.5),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'LoadingIndicator:',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildFeatureItem(
//                       '✓ Kích thước tùy chỉnh (size, strokeWidth)',
//                     ),
//                     _buildFeatureItem('✓ Màu sắc tùy chỉnh'),
//                     _buildFeatureItem('✓ Hiển thị message tùy chọn'),
//                     _buildFeatureItem('✓ Nhẹ nhàng, có thể nhúng bất kỳ đâu'),
//                     const SizedBox(height: 16),
//                     Text(
//                       'FullScreenLoading:',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildFeatureItem('✓ Overlay toàn màn hình'),
//                     _buildFeatureItem('✓ Chế độ sáng/tối (isDark)'),
//                     _buildFeatureItem('✓ Hiển thị message'),
//                     _buildFeatureItem('✓ Chặn tương tác khi loading'),
//                     _buildFeatureItem(
//                       '✓ LoadingOverlay helper (show/hide dễ dàng)',
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 60),

//               // Toast Section
//               _buildSectionTitle('Toast / Snackbar - Thông báo'),
//               const SizedBox(height: 20),

//               Text(
//                 'CustomToast là component thông báo với animation, auto-dismiss và nhiều loại khác nhau.',
//                 style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
//               ),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       'Toast Types',
//                       style: AppTextStyles.labelLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Success Toast
//                     PrimaryButton(
//                       title: 'Success Toast',
//                       icon: Icons.check_circle,
//                       onPress: () {
//                         Toast.success(
//                           context,
//                           'Đấu giá thành công! Bạn đang dẫn đầu.',
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     // Error Toast
//                     PrimaryButton(
//                       title: 'Error Toast',
//                       icon: Icons.error,
//                       onPress: () {
//                         Toast.error(
//                           context,
//                           'Không thể kết nối đến server. Vui lòng thử lại.',
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     // Warning Toast
//                     PrimaryButton(
//                       title: 'Warning Toast',
//                       icon: Icons.warning,
//                       onPress: () {
//                         Toast.warning(
//                           context,
//                           'Số dư ví của bạn đang thấp. Vui lòng nạp thêm.',
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     // Info Toast
//                     PrimaryButton(
//                       title: 'Info Toast',
//                       icon: Icons.info,
//                       onPress: () {
//                         Toast.info(
//                           context,
//                           'Cuộc đấu giá sẽ kết thúc trong 5 phút nữa.',
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Toast Positions'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     SecondaryButton(
//                       title: 'Toast ở trên (Top)',
//                       icon: Icons.arrow_upward,
//                       onPress: () {
//                         Toast.show(
//                           context,
//                           message: 'Toast hiển thị ở phía trên màn hình',
//                           type: ToastType.info,
//                           position: ToastPosition.top,
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     SecondaryButton(
//                       title: 'Toast ở dưới (Bottom)',
//                       icon: Icons.arrow_downward,
//                       onPress: () {
//                         Toast.show(
//                           context,
//                           message: 'Toast hiển thị ở phía dưới màn hình',
//                           type: ToastType.success,
//                           position: ToastPosition.bottom,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Custom Duration'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     SecondaryButton(
//                       title: 'Toast 1 giây',
//                       onPress: () {
//                         Toast.show(
//                           context,
//                           message: 'Toast này sẽ biến mất sau 1 giây',
//                           duration: const Duration(seconds: 1),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     SecondaryButton(
//                       title: 'Toast 5 giây',
//                       onPress: () {
//                         Toast.show(
//                           context,
//                           message: 'Toast này sẽ hiển thị lâu hơn (5 giây)',
//                           type: ToastType.warning,
//                           duration: const Duration(seconds: 5),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),

//               _buildSectionTitle('Tính năng Toast'),
//               const SizedBox(height: 20),

//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryLight,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.secondary.withOpacity(0.5),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildFeatureItem(
//                       '✓ 4 loại: Success, Error, Warning, Info',
//                     ),
//                     _buildFeatureItem('✓ Vị trí: Top hoặc Bottom'),
//                     _buildFeatureItem('✓ Auto dismiss với thời gian tùy chỉnh'),
//                     _buildFeatureItem('✓ Nút đóng thủ công'),
//                     _buildFeatureItem('✓ Slide & Fade animation mượt mà'),
//                     _buildFeatureItem('✓ Icon và màu sắc theo type'),
//                     _buildFeatureItem(
//                       '✓ Helper methods tiện lợi (Toast.success, Toast.error...)',
//                     ),
//                     _buildFeatureItem(
//                       '✓ Tự động remove toast cũ khi show toast mới',
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Light FullScreenLoading Overlay
//         FullScreenLoading(
//           visible: _showFullScreenLoading,
//           message: 'Đang xử lý...\nVui lòng chờ',
//         ),

//         // Dark FullScreenLoading Overlay
//         FullScreenLoading(
//           visible: _showDarkLoading,
//           message: 'Đang tải dữ liệu...\nVui lòng chờ',
//           isDark: true,
//         ),
//       ],
//     );
//   }

//   // UserAvatar Demo Tab
//   Widget _buildUserAvatarTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('UserAvatar - Các size khác nhau'),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Column(
//                 children: [
//                   const UserAvatar(name: 'Hồ Chân', size: 40),
//                   const SizedBox(height: 8),
//                   Text('Small (40)', style: AppTextStyles.bodySmall),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const UserAvatar(name: 'Hồ Chân', size: 56),
//                   const SizedBox(height: 8),
//                   Text('Medium (56)', style: AppTextStyles.bodySmall),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const UserAvatar(name: 'Hồ Chân', size: 72),
//                   const SizedBox(height: 8),
//                   Text('Large (72)', style: AppTextStyles.bodySmall),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 40),
//           _buildSectionTitle('Với ảnh URL'),
//           const SizedBox(height: 20),
//           Center(
//             child: UserAvatar(
//               name: 'Nguyễn Văn A',
//               imageUrl: 'https://i.pravatar.cc/150?img=1', // Ảnh random avatar
//               size: 80,
//             ),
//           ),
//           const SizedBox(height: 40),
//           _buildSectionTitle('Khác nhau tên người dùng'),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: const [
//               UserAvatar(name: 'Hồ Chân', size: 56),
//               UserAvatar(name: 'Trần Minh', size: 56),
//               UserAvatar(name: 'A', size: 56),
//               UserAvatar(name: '', size: 56),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // AuctionCard Demo Tab
//   Widget _buildAuctionCardTab() {
//     final demoAuction = AuctionModel(
//       id: 'demo_1',
//       title: 'Vintage Rolex Submariner 1980',
//       description: 'A classic timepiece in excellent condition.',
//       images: ['https://picsum.photos/400/300'],
//       status: 'ACTIVE',
//       startPriceVnd: 150000000,
//       currentPriceVnd: 165000000,
//       stepPriceVnd: 1000000,
//       formattedCurrentPrice: '165,000,000 VND',
//       endTime: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
//       seller: UserEntity(
//         id: 'seller_1',
//         username: 'watch_collector',
//         email: 'collector@example.com',
//         fullName: 'Watch Collector',
//         role: 'USER',
//         walletAddress: '0x123...',
//         createdAt: DateTime.now(),
//       ),
//       createdAt: DateTime.now(),
//     );

//     final demoAuctionNoImage = AuctionModel(
//       id: 'demo_2',
//       title: 'Antique Vase Ming Dynasty',
//       description: 'Rare artifact.',
//       images: [],
//       status: 'ACTIVE',
//       startPriceVnd: 50000000,
//       currentPriceVnd: 50000000,
//       stepPriceVnd: 500000,
//       formattedCurrentPrice: '50,000,000 VND',
//       endTime: DateTime.now().add(const Duration(days: 1)),
//       seller: UserEntity(
//         id: 'seller_2',
//         username: 'antique_shop',
//         email: 'shop@example.com',
//         fullName: 'Antique Shop',
//         role: 'USER',
//         walletAddress: '0x456...',
//         createdAt: DateTime.now(),
//       ),
//       createdAt: DateTime.now(),
//     );

//     final demoAuctionEndingSoon = AuctionModel(
//       id: 'demo_3',
//       title: 'Gaming Laptop Alienware',
//       description: 'High performance gaming laptop.',
//       images: ['https://picsum.photos/400/300?random=2'],
//       status: 'ACTIVE',
//       startPriceVnd: 30000000,
//       currentPriceVnd: 32000000,
//       stepPriceVnd: 500000,
//       formattedCurrentPrice: '32,000,000 VND',
//       endTime: DateTime.now().add(const Duration(minutes: 15)),
//       seller: UserEntity(
//         id: 'seller_3',
//         username: 'gamer_pro',
//         email: 'gamer@example.com',
//         fullName: 'Gamer Pro',
//         role: 'USER',
//         walletAddress: '0x789...',
//         createdAt: DateTime.now(),
//       ),
//       createdAt: DateTime.now(),
//     );

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionTitle('AuctionCard - Với ảnh'),
//           const SizedBox(height: 16),
//           AuctionCard(auction: demoAuction),
//           const SizedBox(height: 24),

//           _buildSectionTitle('AuctionCard - Không có ảnh'),
//           const SizedBox(height: 16),
//           AuctionCard(auction: demoAuctionNoImage),
//           const SizedBox(height: 24),

//           _buildSectionTitle('AuctionCard - Sắp hết thời gian'),
//           const SizedBox(height: 16),
//           AuctionCard(auction: demoAuctionEndingSoon),
//         ],
//       ),
//     );
//   }

//   // EmptyState Demo Tab
//   Widget _buildEmptyStateTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle('EmptyState - Không có cuộc đấu giá'),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: 400,
//               child: EmptyState(
//                 icon: Icons.shopping_bag_outlined,
//                 title: 'Chưa có cuộc đấu giá',
//                 description:
//                     'Hãy khám phá những cuộc đấu giá hấp dẫn hoặc tạo cuộc đấu giá của riêng bạn',
//                 actionLabel: 'Khám phá ngay',
//                 onActionPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Navigating to auctions...')),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 40),
//             _buildSectionTitle('EmptyState - Tìm kiếm không có kết quả'),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: 300,
//               child: EmptyState(
//                 icon: Icons.search_off,
//                 title: 'Không tìm thấy kết quả',
//                 description: 'Thử lại với từ khóa khác',
//                 iconColor: AppColors.secondary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ErrorView Demo Tab
//   Widget _buildErrorViewTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle('ErrorView - Lỗi kết nối'),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: 400,
//               child: ErrorView(
//                 message:
//                     'Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối internet của bạn.',
//                 onRetry: () {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(const SnackBar(content: Text('Retrying...')));
//                 },
//               ),
//             ),
//             const SizedBox(height: 40),
//             _buildSectionTitle('ErrorView - Với nút Đóng'),
//             const SizedBox(height: 20),
//             SizedBox(
//               height: 450,
//               child: ErrorView(
//                 title: 'Đã xảy ra lỗi',
//                 message:
//                     'Cuộc đấu giá không tồn tại hoặc đã bị xóa. Vui lòng quay lại danh sách.',
//                 icon: Icons.warning_outlined,
//                 retryLabel: 'Thử lại',
//                 onRetry: () {},
//                 closeLabel: 'Quay lại',
//                 onClose: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: AppTextStyles.h4.copyWith(color: AppColors.accent),
//     );
//   }
// }

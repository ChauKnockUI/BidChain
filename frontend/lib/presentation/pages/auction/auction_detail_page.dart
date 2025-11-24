import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  bool _loading = true;
  Map<String, dynamic>? _auction;
  final _bidController = TextEditingController();
  bool _bidding = false;

  @override
  void initState() {
    super.initState();
    _loadAuction();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  Future<void> _loadAuction() async {
    // TODO: replace with repository/usecase call to backend
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _auction = {
        'id': widget.auctionId,
        'title': 'Sample Auction #${widget.auctionId}',
        'currentBid': '0.25 ETH',
        'endTime': DateTime.now().add(const Duration(hours: 2)),
        'bidCount': 3,
        'metadataUrl': 'https://ipfs.io/...',
      };
      _loading = false;
    });
  }

  Future<void> _openBidDialog() async {
    _bidController.text = '';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Place a bid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _bidController,
              label: 'Amount (ETH)',
              hint: '0.1',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter amount';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Invalid amount';
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = _bidController.text.trim();
              if (amount.isEmpty || double.tryParse(amount) == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
                return;
              }
              Navigator.of(ctx).pop();
              await _placeBid(amount);
            },
            child: const Text('Bid'),
          )
        ],
      ),
    );
  }

  Future<void> _placeBid(String amount) async {
    setState(() => _bidding = true);
    // TODO: call placeBid usecase -> repository -> backend/contract
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _bidding = false;
      // update local placeholder
      _auction?['currentBid'] = '$amount ETH';
      _auction?['bidCount'] = (_auction?['bidCount'] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid submitted (simulated)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Auction Detail'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_auction!['title'], style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text('Current bid: ${_auction!['currentBid']}', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Text('Bids: ${_auction!['bidCount']}', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text('Ends: ${(_auction!['endTime'] as DateTime).toLocal()}', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 16),
                  Text('Metadata', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 6),
                  Text(_auction!['metadataUrl'], style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomButton(
                      text: _bidding ? 'Bidding...' : 'Place Bid',
                      isLoading: _bidding,
                      onPressed: _bidding ? null : _openBidDialog,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
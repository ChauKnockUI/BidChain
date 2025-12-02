import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import 'countdown_timer.dart';

class PlaceBidDialog extends StatefulWidget {
  final double currentPrice;
  final double stepPrice;
  final String formattedCurrentPrice;
  final String formattedStepPrice;
  final DateTime endTime;
  final Function(double) onPlaceBid;

  const PlaceBidDialog({
    super.key,
    required this.currentPrice,
    required this.stepPrice,
    required this.formattedCurrentPrice,
    required this.formattedStepPrice,
    required this.endTime,
    required this.onPlaceBid,
  });

  @override
  State<PlaceBidDialog> createState() => _PlaceBidDialogState();
}

class _PlaceBidDialogState extends State<PlaceBidDialog> {
  late TextEditingController _controller;
  double? _bidAmount;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final minBid = widget.currentPrice + widget.stepPrice;
    _bidAmount = minBid;
    _controller = TextEditingController(text: minBid.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndSetBid(String value) {
    setState(() {
      _errorMessage = null;
      if (value.isEmpty) {
        _bidAmount = null;
        return;
      }

      final amount = double.tryParse(value);
      if (amount == null) {
        _errorMessage = 'Số tiền không hợp lệ';
        _bidAmount = null;
        return;
      }

      final minBid = widget.currentPrice + widget.stepPrice;
      if (amount < minBid) {
        _errorMessage = 'Giá tối thiểu: ${minBid.toStringAsFixed(0)} ₫';
        _bidAmount = null;
        return;
      }

      _bidAmount = amount;
    });
  }

  void _quickBid(double multiplier) {
    final amount = widget.currentPrice + (widget.stepPrice * multiplier);
    _controller.text = amount.toStringAsFixed(0);
    _validateAndSetBid(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final minBid = widget.currentPrice + widget.stepPrice;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Đặt giá',
              style: AppTextStyles.h3.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 16),

            // Large Timer Display
            Center(
              child: CountdownTimer(
                endTime: widget.endTime,
                showLarge: true,
              ),
            ),
            const SizedBox(height: 20),

            // Current Price Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giá hiện tại:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        widget.formattedCurrentPrice,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bước giá:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        widget.formattedStepPrice,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bid Amount Input
            Text(
              'Số tiền đặt giá',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                suffixText: '₫',
                errorText: _errorMessage,
              ),
              onChanged: _validateAndSetBid,
            ),
            const SizedBox(height: 16),

            // Quick Bid Buttons
            Text(
              'Đặt nhanh',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickBidButton(
                  label: '+${widget.formattedStepPrice}',
                  onTap: () => _quickBid(1),
                ),
                _QuickBidButton(
                  label: '+${(widget.stepPrice * 2).toStringAsFixed(0)} ₫',
                  onTap: () => _quickBid(2),
                ),
                _QuickBidButton(
                  label: '+${(widget.stepPrice * 5).toStringAsFixed(0)} ₫',
                  onTap: () => _quickBid(5),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _bidAmount != null && _bidAmount! >= minBid
                        ? () {
                            widget.onPlaceBid(_bidAmount!);
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBidButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBidButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.tertiary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.tertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

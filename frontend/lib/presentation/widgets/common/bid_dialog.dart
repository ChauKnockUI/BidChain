import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'form_input.dart';

class BidDialog extends StatefulWidget {
  final bool visible;
  final VoidCallback onClose;
  final Function(double bidAmount) onConfirm;
  final double? defaultValue;
  final double? currentBid;
  final double? minimumBid;
  final String? title;
  final String? description;

  const BidDialog({
    super.key,
    required this.visible,
    required this.onClose,
    required this.onConfirm,
    this.defaultValue,
    this.currentBid,
    this.minimumBid,
    this.title,
    this.description,
  });

  @override
  State<BidDialog> createState() => _BidDialogState();
}

class _BidDialogState extends State<BidDialog> {
  late String _bidAmount;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bidAmount = widget.defaultValue?.toString() ?? '';
  }

  @override
  void didUpdateWidget(BidDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      // Reset state when dialog opens
      setState(() {
        _bidAmount = widget.defaultValue?.toString() ?? '';
        _errorMessage = '';
        _isLoading = false;
      });
    }
  }

  void _validateAndConfirm() {
    setState(() {
      _errorMessage = '';
    });

    // Validate empty
    if (_bidAmount.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập số tiền đấu giá';
      });
      return;
    }

    // Parse amount
    final double? amount = double.tryParse(_bidAmount);
    if (amount == null) {
      setState(() {
        _errorMessage = 'Số tiền không hợp lệ';
      });
      return;
    }

    // Validate minimum bid
    if (widget.minimumBid != null && amount < widget.minimumBid!) {
      setState(() {
        _errorMessage =
            'Số tiền phải lớn hơn ${_formatCurrency(widget.minimumBid!)}';
      });
      return;
    }

    // Validate higher than current bid
    if (widget.currentBid != null && amount <= widget.currentBid!) {
      setState(() {
        _errorMessage =
            'Số tiền phải cao hơn giá hiện tại ${_formatCurrency(widget.currentBid!)}';
      });
      return;
    }

    // All validations passed
    setState(() {
      _isLoading = true;
    });

    widget.onConfirm(amount);

    // Reset loading state after a delay (simulating API call)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ETH';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Dialog
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.gavel,
                              color: AppColors.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title ?? 'Đặt giá đấu',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.accentDark,
                                  ),
                                ),
                                if (widget.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.description!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                            color: AppColors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Current Bid Info
                      if (widget.currentBid != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giá hiện tại:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.grey,
                                ),
                              ),
                              Text(
                                _formatCurrency(widget.currentBid!),
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Minimum Bid Info
                      if (widget.minimumBid != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Giá tối thiểu: ${_formatCurrency(widget.minimumBid!)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Bid Input
                      FormInput(
                        label: 'Số tiền đấu giá (ETH)',
                        value: _bidAmount,
                        onChangeText: (value) {
                          setState(() {
                            _bidAmount = value;
                            _errorMessage = '';
                          });
                        },
                        error: _errorMessage,
                        hint: 'Nhập số tiền bạn muốn đấu',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: Icons.attach_money,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 8),

                      // Quick Bid Buttons
                      Text(
                        'Đấu nhanh:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickBidChip('+0.1 ETH'),
                          _buildQuickBidChip('+0.5 ETH'),
                          _buildQuickBidChip('+1 ETH'),
                          _buildQuickBidChip('+5 ETH'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              title: 'Hủy',
                              onPress: widget.onClose,
                              height: 48,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: PrimaryButton(
                              title: 'Xác nhận đấu giá',
                              onPress: _validateAndConfirm,
                              loading: _isLoading,
                              height: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBidChip(String label) {
    return InkWell(
      onTap: () {
        final increment =
            double.tryParse(label.replaceAll('+', '').replaceAll(' ETH', '')) ??
            0;
        final currentAmount =
            double.tryParse(_bidAmount) ?? widget.currentBid ?? 0;
        setState(() {
          _bidAmount = (currentAmount + increment).toString();
          _errorMessage = '';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

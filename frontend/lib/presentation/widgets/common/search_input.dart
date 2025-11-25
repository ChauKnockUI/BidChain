import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class SearchInput extends StatefulWidget {
  final String placeholder;
  final ValueChanged<String> onChangeText;
  final String? initialValue;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;

  const SearchInput({
    super.key,
    required this.placeholder,
    required this.onChangeText,
    this.initialValue,
    this.onClear,
    this.onSearch,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChangeText('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChangeText,
        onSubmitted: (_) {
          if (widget.onSearch != null) {
            widget.onSearch!();
          }
        },
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey.withOpacity(0.6),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          // Search Icon
          prefixIcon: Icon(
            Icons.search,
            color: _isFocused ? AppColors.accent : AppColors.grey,
            size: 22,
          ),

          // Clear Button (hiển thị khi có text)
          suffixIcon: hasText
              ? IconButton(
                  icon: Icon(Icons.close, color: AppColors.grey, size: 20),
                  onPressed: _clearSearch,
                )
              : null,

          // Border styles
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
      ),
    );
  }
}

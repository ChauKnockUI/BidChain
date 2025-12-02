import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class BioInput extends StatefulWidget {
  final String? initialBio;
  final Function(String?) onBioChanged;

  const BioInput({super.key, this.initialBio, required this.onBioChanged});

  @override
  State<BioInput> createState() => _BioInputState();
}

class _BioInputState extends State<BioInput> {
  late TextEditingController _bioCtrl;
  final int maxBioLength = 500;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(text: widget.initialBio ?? '');
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio (Optional)',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _bioCtrl,
          maxLines: 4,
          maxLength: maxBioLength,
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.greyLight,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            counterText: '${_bioCtrl.text.length}/$maxBioLength',
          ),
          onChanged: (value) {
            setState(() {});
            widget.onBioChanged(value.isEmpty ? null : value);
          },
        ),
      ],
    );
  }
}

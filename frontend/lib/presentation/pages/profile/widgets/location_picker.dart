import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/data/location_data.dart';

class LocationPicker extends StatefulWidget {
  final String? initialCountry;
  final String? initialCity;
  final String? initialDistrict;
  final String? initialWard;
  final String? initialAddress;
  final Function(String?, String?, String?, String?, String?) onLocationChanged;

  const LocationPicker({
    super.key,
    this.initialCountry,
    this.initialCity,
    this.initialDistrict,
    this.initialWard,
    this.initialAddress,
    required this.onLocationChanged,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late String? selectedCountry;
  late String? selectedCity;
  late String? selectedDistrict;
  late String? selectedWard;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialCountry;
    selectedCity = widget.initialCity;
    selectedDistrict = widget.initialDistrict;
    selectedWard = widget.initialWard;
    addressCtrl = TextEditingController(text: widget.initialAddress ?? '');
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onLocationChanged(
      selectedCountry,
      selectedCity,
      selectedDistrict,
      selectedWard,
      addressCtrl.text.isEmpty ? null : addressCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final countries = LocationData.getCountries();
    final cities = selectedCountry != null
        ? LocationData.getCities(selectedCountry!)
        : [];
    final districts = selectedCity != null
        ? LocationData.getDistricts(selectedCity!)
        : [];
    final wards = selectedDistrict != null
        ? LocationData.getWards(selectedDistrict!)
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Country',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedCountry,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: countries.map<DropdownMenuItem<String>>((country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedCity = null;
                    selectedDistrict = null;
                    selectedWard = null;
                  });
                  _notifyChange();
                },
              ),
            ],
          ),
        ),

        // City
        if (selectedCountry != null && cities.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'City/Province',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.greyLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: cities.map<DropdownMenuItem<String>>((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      selectedDistrict = null;
                      selectedWard = null;
                    });
                    _notifyChange();
                  },
                ),
              ],
            ),
          ),

        // District
        if (selectedCity != null && districts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'District',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.greyLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: districts.map<DropdownMenuItem<String>>((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedWard = null;
                    });
                    _notifyChange();
                  },
                ),
              ],
            ),
          ),

        // Ward
        if (selectedDistrict != null && wards.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ward',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedWard,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.greyLight,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: wards.map<DropdownMenuItem<String>>((ward) {
                    return DropdownMenuItem<String>(
                      value: ward,
                      child: Text(ward),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedWard = value;
                    });
                    _notifyChange();
                  },
                ),
              ],
            ),
          ),

        // Address detail
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address Detail (Optional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter detailed address...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => _notifyChange(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

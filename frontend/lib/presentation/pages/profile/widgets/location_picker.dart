import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/location_service.dart';

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

  late LocationService _locationService;

  List<String> countries = [];
  List<String> cities = [];
  List<String> districts = [];
  List<String> wards = [];

  bool isLoadingCountries = false;
  bool isLoadingCities = false;
  bool isLoadingDistricts = false;
  bool isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    _locationService = InjectionContainer.getLocationService();

    selectedCountry = widget.initialCountry;
    selectedCity = widget.initialCity;
    selectedDistrict = widget.initialDistrict;
    selectedWard = widget.initialWard;
    addressCtrl = TextEditingController(text: widget.initialAddress ?? '');

    _loadCountries();
    if (selectedCountry != null) {
      _loadCities(selectedCountry!);
      if (selectedCity != null) {
        _loadDistricts(selectedCity!);
        if (selectedDistrict != null) {
          _loadWards(selectedDistrict!);
        }
      }
    }
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => isLoadingCountries = true);
    try {
      final result = await _locationService.getCountries();
      setState(() {
        countries = result;
        isLoadingCountries = false;
      });
    } catch (e) {
      print('Error loading countries: $e');
      setState(() => isLoadingCountries = false);
    }
  }

  Future<void> _loadCities(String country) async {
    setState(() {
      isLoadingCities = true;
      cities = [];
    });
    try {
      final result = await _locationService.getCities(country);
      setState(() {
        cities = result;
        isLoadingCities = false;
      });
    } catch (e) {
      print('Error loading cities: $e');
      setState(() => isLoadingCities = false);
    }
  }

  Future<void> _loadDistricts(String city) async {
    setState(() {
      isLoadingDistricts = true;
      districts = [];
    });
    try {
      final result = await _locationService.getDistricts(city);
      setState(() {
        districts = result;
        isLoadingDistricts = false;
      });
    } catch (e) {
      print('Error loading districts: $e');
      setState(() => isLoadingDistricts = false);
    }
  }

  Future<void> _loadWards(String district) async {
    setState(() {
      isLoadingWards = true;
      wards = [];
    });
    try {
      final result = await _locationService.getWards(district);
      setState(() {
        wards = result;
        isLoadingWards = false;
      });
    } catch (e) {
      print('Error loading wards: $e');
      setState(() => isLoadingWards = false);
    }
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
              isLoadingCountries
                  ? const SizedBox(
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : DropdownButtonFormField<String>(
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
                          cities = [];
                          districts = [];
                          wards = [];
                        });
                        if (value != null) {
                          _loadCities(value);
                        }
                        _notifyChange();
                      },
                    ),
            ],
          ),
        ),

        // City
        if (selectedCountry != null)
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
                isLoadingCities
                    ? const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.greyLight,
                              width: 1,
                            ),
                          ),
                        ),
                        items: cities.map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: cities.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedCity = value;
                                  selectedDistrict = null;
                                  selectedWard = null;
                                  districts = [];
                                  wards = [];
                                });
                                if (value != null) {
                                  _loadDistricts(value);
                                }
                                _notifyChange();
                              },
                      ),
              ],
            ),
          ),

        // District
        if (selectedCity != null)
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
                isLoadingDistricts
                    ? const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.greyLight,
                              width: 1,
                            ),
                          ),
                        ),
                        items: districts.map<DropdownMenuItem<String>>((
                          district,
                        ) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: districts.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  selectedDistrict = value;
                                  selectedWard = null;
                                  wards = [];
                                });
                                if (value != null) {
                                  _loadWards(value);
                                }
                                _notifyChange();
                              },
                      ),
              ],
            ),
          ),

        // Ward
        if (selectedDistrict != null)
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
                isLoadingWards
                    ? const SizedBox(
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : DropdownButtonFormField<String>(
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
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.greyLight,
                              width: 1,
                            ),
                          ),
                        ),
                        items: wards.map<DropdownMenuItem<String>>((ward) {
                          return DropdownMenuItem<String>(
                            value: ward,
                            child: Text(ward),
                          );
                        }).toList(),
                        onChanged: wards.isEmpty
                            ? null
                            : (value) {
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

import '../network/dio_client.dart';

class LocationService {
  final DioClient dioClient;

  // Cache for location data
  List<String>? _countriesCache;
  Map<String, List<String>>? _citiesCache;
  Map<String, List<String>>? _districtsCache;
  Map<String, List<String>>? _wardsCache;

  LocationService({required this.dioClient});

  /// Fetch all countries
  Future<List<String>> getCountries() async {
    try {
      // Return cached data if available
      if (_countriesCache != null) {
        print(
          '[LocationService] Returning cached countries: ${_countriesCache!.length} items',
        );
        return _countriesCache!;
      }

      print('[LocationService] Fetching countries from backend...');
      final response = await dioClient.get('/location/countries');

      print(
        '[LocationService] Countries response status: ${response.statusCode}',
      );
      print(
        '[LocationService] Countries response data type: ${response.data.runtimeType}',
      );
      print('[LocationService] Countries response data: ${response.data}');

      if (response.statusCode == 200) {
        List<String> countries = [];

        if (response.data is List) {
          // If response is already a list of country names
          countries = List<String>.from(response.data);
          print(
            '[LocationService] Parsed as direct list: ${countries.length} countries',
          );
        } else if (response.data is Map && response.data['data'] is List) {
          // If response has data wrapper
          countries = List<String>.from(response.data['data']);
          print(
            '[LocationService] Parsed as wrapped list: ${countries.length} countries',
          );
        } else {
          print('[LocationService] Unexpected response format');
          return [];
        }

        _countriesCache = countries;
        print('[LocationService] Countries cached successfully');
        return countries;
      }

      print('[LocationService] Unexpected status code: ${response.statusCode}');
      return [];
    } catch (e) {
      print('[LocationService] Error fetching countries: $e');
      return [];
    }
  }

  /// Fetch cities for a specific country
  Future<List<String>> getCities(String country) async {
    try {
      // Return cached data if available
      if (_citiesCache != null && _citiesCache!.containsKey(country)) {
        return _citiesCache![country] ?? [];
      }

      final response = await dioClient.get('/location/cities/$country');

      if (response.statusCode == 200) {
        List<String> cities = [];

        if (response.data is List) {
          cities = List<String>.from(response.data);
        } else if (response.data is Map && response.data['data'] is List) {
          cities = List<String>.from(response.data['data']);
        }

        // Cache the result
        _citiesCache ??= {};
        _citiesCache![country] = cities;

        return cities;
      }

      return [];
    } catch (e) {
      print('Error fetching cities for $country: $e');
      return [];
    }
  }

  /// Fetch districts for a specific city
  Future<List<String>> getDistricts(String city) async {
    try {
      // Return cached data if available
      if (_districtsCache != null && _districtsCache!.containsKey(city)) {
        return _districtsCache![city] ?? [];
      }

      final response = await dioClient.get('/location/districts/$city');

      if (response.statusCode == 200) {
        List<String> districts = [];

        if (response.data is List) {
          districts = List<String>.from(response.data);
        } else if (response.data is Map && response.data['data'] is List) {
          districts = List<String>.from(response.data['data']);
        }

        // Cache the result
        _districtsCache ??= {};
        _districtsCache![city] = districts;

        return districts;
      }

      return [];
    } catch (e) {
      print('Error fetching districts for $city: $e');
      return [];
    }
  }

  /// Fetch wards for a specific district
  Future<List<String>> getWards(String district) async {
    try {
      // Return cached data if available
      if (_wardsCache != null && _wardsCache!.containsKey(district)) {
        return _wardsCache![district] ?? [];
      }

      final response = await dioClient.get('/location/wards/$district');

      if (response.statusCode == 200) {
        List<String> wards = [];

        if (response.data is List) {
          wards = List<String>.from(response.data);
        } else if (response.data is Map && response.data['data'] is List) {
          wards = List<String>.from(response.data['data']);
        }

        // Cache the result
        _wardsCache ??= {};
        _wardsCache![district] = wards;

        return wards;
      }

      return [];
    } catch (e) {
      print('Error fetching wards for $district: $e');
      return [];
    }
  }

  /// Clear all cached data
  void clearCache() {
    _countriesCache = null;
    _citiesCache = null;
    _districtsCache = null;
    _wardsCache = null;
  }
}

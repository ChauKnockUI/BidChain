import 'package:http/http.dart' as http;
import 'dart:convert';

class AuctionDataSource {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Get top expensive auctions (only APPROVED and ACTIVE)
  Future<List<Map<String, dynamic>>> getTopExpensiveAuctions({
    int limit = 5,
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/auction/all'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Raw auction data: $data');

        final List<dynamic> auctions = data is List
            ? data
            : data['auctions'] ?? [];
        print('Total auctions fetched: ${auctions.length}');

        // Filter only APPROVED and ACTIVE auctions
        final filtered = auctions.whereType<Map<String, dynamic>>().where((
          auction,
        ) {
          final status = auction['status'] ?? '';
          return status == 'ACTIVE' || status == 'APPROVED';
        }).toList();

        print('Filtered approved/active auctions: ${filtered.length}');

        // Sort by current_price descending and take top items
        filtered.sort((a, b) {
          // Try different price field names
          final priceA =
              (a['current_price_vnd'] ??
                      a['current_price'] ??
                      a['start_price_vnd'] ??
                      a['start_price'] ??
                      0)
                  as num;
          final priceB =
              (b['current_price_vnd'] ??
                      b['current_price'] ??
                      b['start_price_vnd'] ??
                      b['start_price'] ??
                      0)
                  as num;
          return priceB.compareTo(priceA);
        });

        final topAuctions = filtered.take(limit).toList().map((auction) {
          // Get category name properly
          final category = auction['category_id'];
          final categoryName = (category is Map)
              ? (category['name'] ?? 'N/A')
              : (category?.toString() ?? 'N/A');

          // Get seller username properly
          final seller = auction['seller_id'];
          final sellerName = (seller is Map)
              ? (seller['username'] ?? 'Unknown')
              : (seller?.toString() ?? 'Unknown');

          return {
            'id': auction['_id']?.toString() ?? '',
            'title': (auction['title'] ?? 'N/A').toString(),
            'current_price':
                (auction['current_price_vnd'] ?? auction['current_price'] ?? 0),
            'formatted_price': (auction['formatted_current_price'] ?? '')
                .toString(),
            'category': categoryName,
            'condition': (auction['condition'] ?? 'N/A').toString(),
            'seller': sellerName,
            'status': (auction['status'] ?? 'N/A').toString(),
          };
        }).toList();

        print('Returning ${topAuctions.length} top expensive auctions');
        return topAuctions;
      } else {
        print('Failed to fetch auctions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching top auctions: $e');
      return [];
    }
  }

  /// Get auctions by category
  Future<List<Map<String, dynamic>>> getAuctionsByCategory({
    required String categoryId,
    int limit = 5,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/auction?category=$categoryId&sortBy=price&order=desc&limit=$limit',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> auctions = data['auctions'] ?? [];

        return auctions
            .map(
              (auction) => {
                'id': auction['_id'] ?? '',
                'title': auction['title'] ?? 'N/A',
                'current_price': auction['current_price'] ?? 0,
                'category': auction['category_id']?['name'] ?? 'N/A',
                'condition': auction['condition'] ?? 'N/A',
                'seller': auction['seller_id']?['username'] ?? 'N/A',
              },
            )
            .toList();
      } else {
        print('Failed to fetch category auctions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching category auctions: $e');
      return [];
    }
  }

  /// Format auctions for chat display
  String formatAuctionsForChat(List<Map<String, dynamic>> auctions) {
    if (auctions.isEmpty) {
      return 'No high-value auctions found on the system currently.';
    }

    final buffer = StringBuffer();
    buffer.writeln('TOP ${auctions.length} MOST EXPENSIVE ITEMS:');
    buffer.writeln('');

    for (int i = 0; i < auctions.length; i++) {
      final auction = auctions[i];
      final price = auction['current_price'] ?? 0;
      final formatted = auction['formatted_price'] ?? 'N/A';

      buffer.writeln('${i + 1}. **${auction['title'] ?? 'N/A'}**');
      buffer.writeln(
        '   💰 Price: ${formatted.isNotEmpty ? formatted : '${price} VND'}',
      );
      buffer.writeln('   📦 Category: ${auction['category'] ?? 'N/A'}');
      buffer.writeln('   ✨ Condition: ${auction['condition'] ?? 'N/A'}');
      buffer.writeln('   👤 Seller: ${auction['seller'] ?? 'Unknown'}');
      buffer.writeln('   📊 Status: ${auction['status'] ?? 'Active'}');
      if (i < auctions.length - 1) buffer.writeln('');
    }
    return buffer.toString();
  }
}

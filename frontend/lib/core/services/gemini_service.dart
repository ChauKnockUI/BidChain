import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants/gemini_config.dart';
import '../../data/datasources/remote/auction_data_source.dart';

class GeminiService {
  final String apiKey;
  late List<Map<String, dynamic>> _chatHistory;
  static const String _storageKey = 'chat_history';
  final AuctionDataSource _auctionDataSource = AuctionDataSource();
  
  // Current auction context
  Map<String, dynamic>? _currentAuctionContext;

  GeminiService() : apiKey = GeminiConfig.apiKey {
    _chatHistory = [];
  }

  /// Set current auction context for chatbot
  void setAuctionContext(Map<String, dynamic>? auctionData) {
    _currentAuctionContext = auctionData;
    if (auctionData != null) {
      print('[CHATBOT] Auction context set: ${auctionData['title']}');
    } else {
      print('[CHATBOT] Auction context cleared');
    }
  }

  /// Build auction context string for AI
  String _buildAuctionContextString() {
    if (_currentAuctionContext == null) return '';
    
    final auction = _currentAuctionContext!;
    final endTime = auction['end_time'];
    String timeRemaining = 'N/A';
    
    if (endTime != null) {
      try {
        final end = DateTime.parse(endTime.toString());
        final now = DateTime.now();
        final diff = end.difference(now);
        if (diff.isNegative) {
          timeRemaining = 'Đã kết thúc';
        } else if (diff.inDays > 0) {
          timeRemaining = '${diff.inDays} ngày ${diff.inHours % 24} giờ';
        } else if (diff.inHours > 0) {
          timeRemaining = '${diff.inHours} giờ ${diff.inMinutes % 60} phút';
        } else {
          timeRemaining = '${diff.inMinutes} phút';
        }
      } catch (e) {
        timeRemaining = 'N/A';
      }
    }

    return '''

📦 THÔNG TIN PHIÊN ĐẤU GIÁ HIỆN TẠI:
- Tên sản phẩm: ${auction['title'] ?? 'N/A'}
- Mô tả: ${auction['description'] ?? 'N/A'}
- Danh mục: ${auction['category'] ?? auction['category_name'] ?? 'N/A'}
- Giá hiện tại: ${_formatPrice(auction['current_price'])} VND
- Giá khởi điểm: ${_formatPrice(auction['start_price'])} VND
- Bước giá: ${_formatPrice(auction['step_price'])} VND
- Số lượt đặt giá: ${auction['bid_count'] ?? 0}
- Thời gian còn lại: $timeRemaining
- Trạng thái: ${auction['status'] ?? 'N/A'}
- Verified on-chain: ${auction['blockchain_id'] != null ? 'Có ✅' : 'Chưa'}
- Contract address: ${auction['contract_address'] ?? 'N/A'}
''';
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'N/A';
    try {
      final numPrice = price is String ? int.tryParse(price) ?? 0 : price as int;
      return numPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return price.toString();
    }
  }


  /// Load chat history from local storage
  Future<void> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _chatHistory = List<Map<String, dynamic>>.from(
          jsonList.map((item) => Map<String, dynamic>.from(item as Map)),
        );
        print('Loaded ${_chatHistory.length} messages from storage');
      } else {
        _chatHistory = [];
      }
    } catch (e) {
      print('Error loading chat history: $e');
      _chatHistory = [];
    }
  }

  /// Save chat history to local storage
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_chatHistory);
      await prefs.setString(_storageKey, jsonString);
      print('Chat history saved');
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  /// Clear stored chat history
  Future<void> clearStoredChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _chatHistory.clear();
      print('Chat history cleared');
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  /// Send message to Gemini via REST API and get response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Check if user is asking about top/expensive items
      String contextualMessage = userMessage;
      final lowerMessage = userMessage.toLowerCase();

      if (lowerMessage.contains('đắt nhất') ||
          lowerMessage.contains('expensive') ||
          lowerMessage.contains('cao nhất') ||
          lowerMessage.contains('highest') ||
          lowerMessage.contains('most valuable') ||
          (lowerMessage.contains('đắt') &&
              lowerMessage.contains('trên hệ thống')) ||
          lowerMessage.contains('top') && lowerMessage.contains('price')) {
        try {
          print('[CHATBOT] Detected auction query, fetching data...');
          // Fetch top expensive auctions
          final topAuctions = await _auctionDataSource.getTopExpensiveAuctions(
            limit: 5,
          );
          if (topAuctions.isNotEmpty) {
            print('[CHATBOT] Got ${topAuctions.length} auctions:');
            for (var a in topAuctions) {
              print(
                '[CHATBOT] - ${a['title']}: ${a['current_price']} (${a['status']})',
              );
            }
            final formattedAuctions = _auctionDataSource.formatAuctionsForChat(
              topAuctions,
            );
            contextualMessage =
                '''$userMessage

Current high-value items on BidChain:
$formattedAuctions

Please reference ONLY these real items when answering. Do not make up or assume any items not in this list.''';
            print('[CHATBOT] Successfully prepared auction context for Gemini');
          } else {
            print('[CHATBOT] No approved/active auctions found');
          }
        } catch (e) {
          print('[CHATBOT] Error fetching auction data: $e');
          // Continue with regular message if auction fetch fails
        }
      }

      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });
      await _saveChatHistory();

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/${GeminiConfig.modelName}:generateContent?key=$apiKey',
      );

      // Build context with auction info if available
      final auctionContext = _buildAuctionContextString();
      final messageWithContext =
          '${GeminiConfig.systemPrompt}$auctionContext\n\nUser: $contextualMessage';

      final requestBody = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': messageWithContext},
            ],
          },
        ],
        'generationConfig': {
          'temperature': GeminiConfig.temperature,
          'maxOutputTokens': GeminiConfig.maxOutputTokens,
          'topP': GeminiConfig.topP,
          'topK': GeminiConfig.topK,
        },
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (text != null && text.isNotEmpty) {
          // Add AI response to history
          _chatHistory.add({
            'role': 'model',
            'parts': [
              {'text': text},
            ],
          });
          await _saveChatHistory();
          return text;
        } else {
          return 'No response from AI';
        }
      } else if (response.statusCode == 400) {
        print('API Error 400: ${response.body}');
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? '';

        if (errorMessage.contains('expired') ||
            errorMessage.contains('invalid')) {
          return '❌ API Key has expired or is invalid. Please update GEMINI_API_KEY in the .env file with a valid key from Google Cloud Console.';
        } else if (errorMessage.contains('not enabled')) {
          return '❌ Gemini API is not enabled in your Google Cloud project. Please enable it in the Google Cloud Console.';
        }
        return 'API configuration error: $errorMessage';
      } else if (response.statusCode == 429) {
        print('🚫 RATE LIMIT: ${response.body}');
        // Parse the error to get retry time
        try {
          final errorBody = jsonDecode(response.body);
          final retryAfter = errorBody['error']?['details']?[0]?['retryDelay'] ?? 'unknown';
          print('🚫 Retry after: $retryAfter');
        } catch (_) {}
        return '⏱️ Đang bị giới hạn. Vui lòng chờ 1 phút rồi thử lại.';
      } else if (response.statusCode == 401) {
        print('🔑 AUTH ERROR: ${response.body}');
        return '❌ API key không hợp lệ. Kiểm tra lại GEMINI_API_KEY.';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Lỗi: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      print('Unexpected error: $e');
      return 'Unexpected error: $e';
    }
  }

  /// Get chat history
  List<Map<String, dynamic>> getChatHistory() {
    return _chatHistory;
  }

  /// Clear chat history
  void clearChatHistory() {
    _chatHistory.clear();
  }

  /// Format auction data for AI context
  String formatAuctionContext(Map<String, dynamic> auctionData) {
    return '''
Current Auction Information:
- Title: ${auctionData['title'] ?? 'N/A'}
- Current Price: ${auctionData['current_price'] ?? 'N/A'} VND
- Start Price: ${auctionData['start_price'] ?? 'N/A'} VND
- Category: ${auctionData['category'] ?? 'N/A'}
- Condition: ${auctionData['condition'] ?? 'N/A'}
- End Time: ${auctionData['end_time'] ?? 'N/A'}
- Bid Count: ${auctionData['bid_count'] ?? 0}
- Description: ${auctionData['description'] ?? 'N/A'}
''';
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants/gemini_config.dart';

class GeminiService {
  final String apiKey;
  late List<Map<String, dynamic>> _chatHistory;
  static const String _storageKey = 'chat_history';

  GeminiService() : apiKey = GeminiConfig.apiKey {
    _chatHistory = [];
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
      // Add user message to history
      _chatHistory.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });
      await _saveChatHistory();

      // Build request with system prompt included
      final List<Map<String, dynamic>> requestContents = [
        {
          'role': 'user',
          'parts': [
            {'text': GeminiConfig.systemPrompt},
          ],
        },
        {
          'role': 'model',
          'parts': [
            {'text': 'I understand. I\'m ready to help!'},
          ],
        },
        ..._chatHistory, // Add all chat history messages
      ];

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=$apiKey',
      );

      final requestBody = {
        'contents': requestContents,
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
        return 'API Key is invalid or Gemini API is not enabled. Please check GEMINI_API_KEY in .env file and ensure Gemini API is enabled on Google Cloud.';
      } else if (response.statusCode == 429) {
        return 'Rate limit exceeded. Please try again later.';
      } else if (response.statusCode == 401) {
        return 'Invalid API key. Please check your configuration.';
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
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

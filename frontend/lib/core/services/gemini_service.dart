import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/constants/gemini_config.dart';

class GeminiService {
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: GeminiConfig.modelName,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        maxOutputTokens: GeminiConfig.maxOutputTokens,
        topP: GeminiConfig.topP,
        topK: GeminiConfig.topK,
      ),
      systemInstruction: Content.text(GeminiConfig.systemPrompt),
    );

    // Initialize chat session
    _chatSession = _model.startChat();
  }

  /// Send message to Gemini and get response
  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        return 'No response from AI';
      }
    } on GenerativeAIException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  /// Get chat history
  List<Content> getChatHistory() {
    return _chatSession.history.toList();
  }

  /// Clear chat history
  void clearChatHistory() {
    _chatSession = _model.startChat();
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

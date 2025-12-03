import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  // Read API key from .env file
  static String get apiKey {
    final key = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY not found in .env file. '
        'Please create a .env file in the frontend directory with GEMINI_API_KEY=your_key_here',
      );
    }
    return key;
  }

  // Model configuration
  static const String modelName = 'gemini-2.0-flash';

  // Chatbot system prompt
  static const String systemPrompt =
      '''You are a helpful AI assistant for BidChain, an online auction platform. Your role is to help users with:

1. **Product Information**: Answer questions about auction items including price, condition, category, and specifications
2. **Bidding Strategies**: Provide advice on bidding tactics and market trends
3. **Market Insights**: Share information about trending items and price predictions
4. **General Auction Help**: Guide users through the auction process

Important Guidelines:
- Be concise and professional in your responses
- When shown auction data, use that data directly to answer user questions about expensive or high-value items
- Do NOT ask users to provide categories or filters if auction data is provided - use the data given to you
- Always prioritize user safety and fair bidding practices
- Keep responses under 150 words unless more detail is requested
- When users ask general questions about the platform, try to help them navigate and explore
- Provide helpful recommendations based on the real auction data you're given

Your tone should be friendly, knowledgeable, and helpful.''';

  // Model parameters
  static const double temperature = 0.7;
  static const int maxOutputTokens = 1024;
  static const double topP = 0.9;
  static const int topK = 40;
}

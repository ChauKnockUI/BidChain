class GeminiConfig {
  // TODO: Replace with your actual Gemini API key
  static const String apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  // Model configuration
  static const String modelName = 'gemini-pro';

  // Chatbot system prompt
  static const String systemPrompt = '''
You are an AI assistant for BidChain, an online auction platform. Your role is to help users:
1. Get information about products being auctioned (price, production year, condition, etc.)
2. Provide market insights about trending items
3. Answer questions about auction bidding strategies
4. Help users make informed bidding decisions

When answering, be concise, helpful, and professional. If you don't have information about a specific product, ask the user for more details.
You have access to the current auction data to provide accurate information.
''';

  // Model parameters
  static const double temperature = 0.7;
  static const int maxOutputTokens = 1024;
  static const double topP = 0.9;
  static const int topK = 40;
}

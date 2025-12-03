# 🔐 Gemini API Setup Guide

## Problem
You're seeing this error:
```
API Error: 400 - {
  "error": {
    "code": 400,
    "message": "API Key not found. Please pass a valid API key.",
    "status": "INVALID_ARGUMENT"
  }
}
```

## Solution

### Step 1: Get Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click "Create API Key"
3. Copy your API key

### Step 2: Create `.env` file
In the `frontend/` directory, create a `.env` file with the following content:

```env
GEMINI_API_KEY=your_api_key_here
ENVIRONMENT=development
```

Replace `your_api_key_here` with your actual API key from Step 1.

### Step 3: Restart Flutter App
After creating the `.env` file, restart your Flutter application:
```bash
cd frontend
flutter clean
flutter pub get
flutter run
```

### Step 4: Verify
- Open the app and navigate to the Home page
- Click the chat bubble
- Try sending a message to the chatbot
- You should see the response from Gemini AI

## Important Notes
- ⚠️ **Never commit your `.env` file to Git!** It contains secrets.
- ✅ Use `.env.example` as a template for other developers
- 🔒 Keep your API key private and secure

## Troubleshooting

### Still getting 400 error?
1. Make sure the `.env` file is in the `frontend/` root directory (same level as `pubspec.yaml`)
2. Check that `GEMINI_API_KEY=` is spelled exactly right
3. Verify your API key is valid and active on Google AI Studio
4. Try running `flutter clean` and then `flutter pub get` again

### API key is valid but still not working?
- Check if flutter_dotenv is properly configured in `pubspec.yaml`
- Make sure `.env` is included in your `pubspec.yaml` assets:
  ```yaml
  flutter:
    assets:
      - .env
  ```

### Rate limit exceeded?
- Google Gemini API has free tier limits
- If you exceed the limit, upgrade to a paid plan or wait before trying again

---

**Last Updated:** December 3, 2025

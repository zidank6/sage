# 🔮 Sage — @grok but for iMessage

An iMessage extension that brings AI-powered answers to your texts. Ask questions, get instant responses, and share them as tamper-proof bubbles.

### Key Features
*   **Context-Aware Chat**: Reads recent messages to provide relevant responses.
*   **Privacy-Friendly**: Your API key is stored securely in Keychain; conversations stay on-device.
*   **Custom Persona**: Adjusts tone based on premium status (Witty/Dry vs. Smart/Detailed).
*   **History & Sync**: Standalone iOS App with synced history and bookmarking.
*   **Copy & Share**: Easily copy responses or share conversations from the History details.

## 🚀 Setup

### Prerequisites
- Xcode 15+
- iOS 17+ device
- xAI API key

### Install

1. Clone and open:
   ```bash
   git clone https://github.com/yourusername/sage.git
   open sage/Sage/Sage.xcodeproj
   ```

2. Add your API key in `MessagesExtension/Resources/Config.plist`:
   ```xml
   <key>xAIAPIKey</key>
   <string>sk-your-key-here</string>
   ```

3. Update bundle identifiers:
   - Sage target: `com.yourname.sage`
   - MessagesExtension: `com.yourname.sage.MessagesExtension`

4. Run on your iPhone (select device, ⌘R)

5. Open Messages → Tap + → Find **Sage**

## 📁 Structure

```
MessagesExtension/
├── Views/
│   └── CompactView.swift      # Bottom drawer UI
├── Services/
│   ├── xAIService.swift    # Streaming API client
│   └── ConfigService.swift    # API key loader
├── Models/
│   ├── Message.swift          # Chat state
│   └── ChatModels.swift       # xAI types
└── Resources/
    ├── Config.plist           # API settings
    └── Assets.xcassets        # App icon
```

## ⚙️ Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `DefaultModel` | grok-3 | xAI model |
| `MaxTokens` | 80 | Response length limit |
| `Temperature` | 0.7 | Creativity (0-1) |

## 📝 License

MIT

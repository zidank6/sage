# 🔮 Sage — AI in iMessage

An iMessage extension that brings AI-powered answers to your texts. Ask questions, get instant responses, and share them as tamper-proof bubbles.

## ✨ Features

- **💬 AI Chat** — Ask anything directly in iMessage
- **⚡ Streaming** — Watch responses appear in real-time
- **🔒 Tamper-Proof** — Responses sent as non-editable rich bubbles
- **📱 Native UI** — Clean SwiftUI bottom drawer interface

## 🚀 Setup

### Prerequisites
- Xcode 15+
- iOS 17+ device
- OpenAI API key

### Install

1. Clone and open:
   ```bash
   git clone https://github.com/yourusername/sage.git
   open sage/Sage/Sage.xcodeproj
   ```

2. Add your API key in `MessagesExtension/Resources/Config.plist`:
   ```xml
   <key>OpenAIAPIKey</key>
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
│   ├── OpenAIService.swift    # Streaming API client
│   └── ConfigService.swift    # API key loader
├── Models/
│   ├── Message.swift          # Chat state
│   └── ChatModels.swift       # OpenAI types
└── Resources/
    ├── Config.plist           # API settings
    └── Assets.xcassets        # App icon
```

## ⚙️ Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `DefaultModel` | gpt-4o | OpenAI model |
| `MaxTokens` | 80 | Response length limit |
| `Temperature` | 0.7 | Creativity (0-1) |

## 📝 License

MIT

# 🔮 Sage — AI Assistant for iMessage

An iMessage app extension that brings AI-powered conversations to your texts. Ask questions, get intelligent responses with streaming, and insert them directly into your chat.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)

## ✨ Features

- **💬 In-Message AI Chat** — Ask questions directly within iMessage
- **⚡ Real-time Streaming** — Watch responses appear word-by-word
- **📋 Context Awareness** — Use selected text from conversation as context
- **📤 One-Tap Insert** — Send AI responses to chat with a single tap
- **🎨 Native UI** — SwiftUI interface with compact/expanded modes
- **🔒 Privacy-First** — API key stored locally, never hardcoded

## 🚀 Quick Start

### Prerequisites

- macOS with Xcode 15+
- iOS 17+ device or Simulator
- OpenAI API key

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sage.git
   cd sage
   ```

2. **Add your API key**
   
   Edit `Sage/MessagesExtension/Resources/Config.plist`:
   ```xml
   <key>OpenAIAPIKey</key>
   <string>sk-your-api-key-here</string>
   ```

3. **Open in Xcode**
   ```bash
   open Sage/Sage.xcodeproj
   ```

4. **Run**
   - Select the `Sage` scheme
   - Choose Messages as the host app when prompted
   - Press ⌘+R

### Testing in Messages

1. Open Messages app in Simulator
2. Compose a new message
3. Tap the app drawer (+ button)
4. Find and tap **Sage**
5. Type a question and tap send!

## 📁 Project Structure

```
Sage/
├── SageApp/                    # Container app (minimal)
│   └── SageApp.swift
├── MessagesExtension/          # iMessage extension
│   ├── MessagesViewController.swift
│   ├── Views/
│   │   ├── ContentView.swift     # Root view (mode switching)
│   │   ├── CompactView.swift     # Minimal input UI
│   │   ├── ExpandedView.swift    # Full chat UI
│   │   └── ChatBubbleView.swift  # Message bubbles
│   ├── Models/
│   │   ├── Message.swift         # ChatMessage + ChatState
│   │   └── ChatModels.swift      # OpenAI API models
│   ├── Services/
│   │   ├── ConfigService.swift   # API key loading
│   │   └── OpenAIService.swift   # OpenAI streaming client
│   └── Resources/
│       └── Config.plist          # API configuration
```

## 🔧 Configuration

Edit `Config.plist` to customize:

| Key | Default | Description |
|-----|---------|-------------|
| `OpenAIAPIKey` | — | Your OpenAI API key |
| `DefaultModel` | `gpt-4o` | Model to use (gpt-4o, gpt-4o-mini, o3) |
| `MaxTokens` | `500` | Maximum response length |
| `Temperature` | `0.7` | Response creativity (0-1) |

## ⚠️ Privacy Notice

- API calls are sent to OpenAI's cloud servers
- Conversation context is included in requests
- API key is stored locally in `Config.plist` (gitignored)
- Never share built apps without regenerating your API key

## 🛠️ Technical Details

### Streaming Implementation

Uses URLSession's async bytes API for SSE (Server-Sent Events):

```swift
for try await line in bytes.lines {
    guard line.hasPrefix("data: ") else { continue }
    let json = String(line.dropFirst(6))
    if json == "[DONE]" { break }
    // Parse and yield delta content
}
```

### Messages Framework Integration

- `MSMessagesAppViewController` bridges to SwiftUI
- Compact mode: Quick input field
- Expanded mode: Full chat history
- `conversation.insert(_:)` sends responses to thread

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.

---

Built with ❤️ using SwiftUI and OpenAI

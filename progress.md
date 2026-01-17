# Progress Log

## Session: 2026-01-17

### Phase 0: Project Setup ✅
- [x] Explored workspace structure
- [x] Found existing `config.md` with API key
- [x] Created `.gitignore` to protect secrets
- [x] Created `AI.md` persona documentation
- [x] Created `mistakes.md` anti-patterns
- [x] Created `plan.md` with phased roadmap
- [x] Create Xcode project with iMessage extension target

### Phase 1: SwiftUI Stub ✅
- [x] Created `MessagesViewController.swift` - bridges MSMessagesAppViewController to SwiftUI
- [x] Created `ContentView.swift` - root view handling presentation styles
- [x] Created `CompactView.swift` - minimal input for compact mode
- [x] Created `ExpandedView.swift` - full chat history view
- [x] Created `ChatBubbleView.swift` - message bubble component
- [x] Created `Message.swift` - ChatMessage model + ChatState observable

### Phase 2: Conversation Context ✅
- [x] Access `conversation.selectedMessage` in `MessagesViewController`
- [x] Display context banner in `ExpandedView`
- [x] Allow dismissing context with X button

### Phase 3: API Key + Basic Request ✅
- [x] Created `ConfigService.swift` - loads from bundled Config.plist
- [x] Created `ChatModels.swift` - Codable structs for OpenAI API
- [x] Created `OpenAIService.swift` - async/await URLSession client

### Phase 4: Streaming SSE ✅
- [x] Implemented `AsyncThrowingStream` for streaming
- [x] SSE parsing with `data:` prefix handling
- [x] `[DONE]` marker detection
- [x] Delta content accumulation

### Phase 5: Streaming UI ✅
- [x] Real-time text display as chunks arrive
- [x] Auto-scroll on message count change
- [x] Loading indicator during generation
- [x] Error banner with retry option

### Phase 6: Send to Chat ✅
- [x] `MSMessage` creation with formatted response
- [x] `conversation.insert(_:completionHandler:)` integration
- [x] "Send to Chat" button on assistant messages

### Phase 7: Polish (Partial)
- [x] Error handling with user-friendly messages
- [x] Dark mode support (native SwiftUI)
- [ ] Model selection UI
- [ ] Privacy warning on first launch
- [ ] Retry mechanism improvements

### Phase 8: Documentation ✅
- [x] README.md with setup instructions
- [ ] Demo video recording

### Decisions Made
1. **Native URLSession over 3rd-party**: Better control for streaming SSE parsing
2. **SwiftUI for UI**: Modern, declarative, works well in extensions
3. **@Observable class**: Using new Observation framework (iOS 17+) for ChatState
4. **Actor for OpenAIService**: Thread-safe API client
5. **SSE parsing**: Line-by-line parsing of `data:` prefixed lines

### Files Created
```
Sage/
├── SageApp/
│   ├── SageApp.swift
│   └── Info.plist
├── MessagesExtension/
│   ├── MessagesViewController.swift
│   ├── Info.plist
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── CompactView.swift
│   │   ├── ExpandedView.swift
│   │   └── ChatBubbleView.swift
│   ├── Models/
│   │   ├── Message.swift
│   │   └── ChatModels.swift
│   ├── Services/
│   │   ├── ConfigService.swift
│   │   └── OpenAIService.swift
│   └── Resources/
│       └── Config.plist
└── Sage.xcodeproj/
    └── project.pbxproj
```

### Next Steps
1. Open project in Xcode and build
2. Test in iOS Simulator with Messages app
3. Add model selection UI
4. Add privacy warning alert
5. Record demo video

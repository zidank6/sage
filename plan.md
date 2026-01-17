# Sage — iMessage AI Assistant Implementation Plan

## Overview
Build an iMessage app extension that lets users ask questions and receive AI-powered responses via OpenAI's Chat Completions API, with streaming support and one-tap insertion into the chat.

---

## Phase 0: Project Setup ✅ (Current)
- [x] Create project documentation (AI.md, mistakes.md, progress.md)
- [x] Create `.gitignore` to protect `config.md` API key
- [ ] Create Xcode project with iMessage extension target

---

## Phase 1: SwiftUI Stub + Compact/Expanded Modes
**Goal**: Basic iMessage extension with SwiftUI UI that responds to presentation style changes.

### Files to Create
| File | Purpose |
|------|---------|
| `SageApp/MessagesExtension/MessagesViewController.swift` | Main VC bridging MSMessagesAppViewController to SwiftUI |
| `SageApp/MessagesExtension/Views/ContentView.swift` | Root SwiftUI view handling compact/expanded |
| `SageApp/MessagesExtension/Views/CompactView.swift` | Minimal input field UI for compact mode |
| `SageApp/MessagesExtension/Views/ExpandedView.swift` | Full chat history UI for expanded mode |

### Deliverable
- Extension launches in Messages app
- Compact mode: Shows input field + "Ask Sage" button
- Expanded mode: Shows scrollable chat history + input

---

## Phase 2: Conversation Context Access
**Goal**: Read selected text from MSConversation.

### Changes
- Access `conversation.selectedMessage` when available
- Display selected text as context in UI
- Handle cases where no text is selected

---

## Phase 3: Secure API Key Handling + Basic POST
**Goal**: Load API key from bundle/config, make a non-streaming request.

### Files to Create
| File | Purpose |
|------|---------|
| `SageApp/MessagesExtension/Services/ConfigService.swift` | Load API key from bundled config |
| `SageApp/MessagesExtension/Services/OpenAIService.swift` | OpenAI API client |
| `SageApp/MessagesExtension/Models/ChatModels.swift` | Request/Response Codable structs |

### Security
- Config file bundled (not hardcoded)
- Never log API key
- Show privacy warning to user

---

## Phase 4: Streaming Chat Completions + SSE Parsing
**Goal**: Implement real-time streaming with Server-Sent Events parsing.

### Implementation
- Use URLSession with `bytes(for:)` async sequence
- Parse SSE format: `data: {...}` lines
- Handle `[DONE]` marker
- Accumulate delta content chunks

---

## Phase 5: Real-Time UI Streaming Display
**Goal**: Show AI response as it streams in.

### Implementation
- `@Observable` class for chat state management
- Update UI on each delta received
- Smooth scrolling as text appears
- Loading indicator during generation

---

## Phase 6: Send-to-Chat MSMessage Bubble
**Goal**: Insert AI response as clean text bubble in conversation.

### Implementation
- Create `MSMessage` with response text
- Use `conversation.insert(_:completionHandler:)`
- Format: "Sage: [response]" or custom attributed text
- Handle insertion errors gracefully

---

## Phase 7: Polish
**Goal**: Production-ready UX.

### Features
- Error handling with user-friendly messages
- Retry mechanism for failed requests
- Loading spinner during API calls
- Model selection (gpt-4o, gpt-4o-mini, o3)
- Dark mode support
- Privacy warning on first launch

---

## Phase 8: README + Demo
**Goal**: Documentation for portfolio.

### Deliverables
- README.md with project overview, setup instructions
- Demo video/screenshots
- Architecture diagram

---

## Verification Plan

### Automated Tests
Since this is an iMessage extension, traditional unit tests are limited. However:

1. **API Models Test** (XCTest)
   ```bash
   xcodebuild test -scheme SageExtension -destination 'platform=iOS Simulator,name=iPhone 15'
   ```
   - Test JSON encoding/decoding for ChatRequest, ChatResponse
   - Test SSE line parsing

2. **Service Tests** (XCTest with mocked URLProtocol)
   - Mock API responses
   - Verify correct request headers
   - Test error handling

### Manual Verification
Each phase will be verified by:

1. **Build & Run**: `Cmd + R` in Xcode, select Messages app as host
2. **UI Testing**: 
   - Open Messages → Compose → Tap app drawer → Find Sage
   - Test compact mode (tap once) vs expanded mode (swipe up)
3. **API Testing** (Phase 3+):
   - Type question → Verify response appears
   - Check streaming animation
   - Test "Send to Chat" button inserts message

### Test Device
- iOS Simulator (iPhone 15, iOS 17+)
- Physical iPhone for final validation (requires developer account)

---

## User Review Required

> [!IMPORTANT]
> **API Key Security**: Your API key is stored in `config.md` which is gitignored. For the extension to access it, I'll bundle it as a resource. Never share the built app without regenerating the key.

> [!WARNING]  
> **iMessage Extension Limitations**: Extensions run sandboxed with limited background execution. Long API calls may timeout if user switches away.

---

## Architecture

```
SageApp/
├── Sage/                           # Container app (minimal)
│   └── SageApp.swift
├── MessagesExtension/              # iMessage extension
│   ├── MessagesViewController.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── CompactView.swift
│   │   ├── ExpandedView.swift
│   │   └── ChatBubbleView.swift
│   ├── Services/
│   │   ├── ConfigService.swift
│   │   └── OpenAIService.swift
│   ├── Models/
│   │   ├── ChatModels.swift
│   │   └── Message.swift
│   └── Resources/
│       └── config.plist
└── Tests/
    └── OpenAIServiceTests.swift
```

---

## Next Step
**Phase 0 Completion**: Create Xcode project with iMessage extension target using:
```bash
# Will need to create project in Xcode (cannot be fully automated via CLI)
# I'll provide exact steps and file contents
```

Type **CONTINUE** to proceed with Phase 0 → Phase 1 (Xcode project + SwiftUI stub).

# Sage — Implementation Plan

## Overview
iMessage extension with AI-powered responses via OpenAI, delivered as tamper-proof rich bubbles.

## Architecture

```
┌─────────────────────┐
│   Messages App      │
└─────────┬───────────┘
          │
┌─────────▼───────────┐
│  MessagesExtension  │
│  ┌───────────────┐  │
│  │ CompactView   │  │  ← Bottom drawer UI
│  └───────┬───────┘  │
│          │          │
│  ┌───────▼───────┐  │
│  │ OpenAIService │  │  ← Streaming API
│  └───────┬───────┘  │
│          │          │
│  ┌───────▼───────┐  │
│  │ MSMessage     │  │  ← Tamper-proof bubble
│  └───────────────┘  │
└─────────────────────┘
```

## Key Constraints

| Constraint | Solution |
|------------|----------|
| Bubble text limit (~150 chars) | Strict system prompt |
| No editing before send | MSMessageTemplateLayout |
| Real-time feedback | SSE streaming |
| API key security | Bundled Config.plist (gitignored) |

## System Prompt Strategy

```
STRICT RULES:
1. Maximum 150 characters total
2. ONE complete thought/answer
3. Numbers and facts first
4. No filler words (use "~" not "approximately")
5. End with period, never mid-sentence
```

## Done
- [x] Xcode project setup
- [x] SwiftUI compact view
- [x] OpenAI streaming integration
- [x] MSMessage rich bubbles
- [x] App icon
- [x] Real device testing

## Future Ideas
- [ ] Model selection (gpt-4o-mini for faster)
- [ ] Conversation memory
- [ ] Image input support
- [ ] Siri Shortcuts integration

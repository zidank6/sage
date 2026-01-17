# Sage — Progress Log

## Session: 2026-01-17

### Completed
- [x] Created Xcode project with container app + Messages extension
- [x] Built SwiftUI UI (CompactView for bottom drawer)
- [x] Integrated OpenAI API with streaming (SSE)
- [x] Added MSMessageTemplateLayout for tamper-proof bubbles
- [x] Added app icon (blue sparkle logo)
- [x] Optimized prompt for 150-char limit to prevent cutoff
- [x] Tested on real iPhone via Xcode
- [x] **Implemented Freemium Model**
    - [x] Created `Sage.storekit` for local testing ($1.99/mo, $19.99/yr)
    - [x] Built `SubscriptionService` (StoreKit 2)
    - [x] Built `UsageService` (Daily limit: 30)
    - [x] Added Paywall (`UpgradeView`)
    - [x] Updated Logic: Free (150 chars, gpt-3.5) vs Premium (300 chars, gpt-4o)

### Key Files
- `SubscriptionService.swift` — Handles IAP
- `UsageService.swift` — Handles daily counts
- `UpgradeView.swift` — Premium paywall
- `Sage.storekit` — Test configuration

### Testing Notes (Freemium)
To test in Simulator:
1. Go to **Product > Scheme > Edit Scheme**
2. Select **Run** > **Options**
3. Set **StoreKit Configuration** to `Sage.storekit`

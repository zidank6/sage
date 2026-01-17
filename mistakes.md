# Mistakes to Avoid

## Security
- ❌ **NEVER** hardcode API keys in Swift files
- ❌ **NEVER** commit `config.md` to git (already in .gitignore)
- ❌ **NEVER** log API keys to console

## API Integration
- ❌ Don't forget `Content-Type: application/json` header
- ❌ Don't forget `Authorization: Bearer <key>` header
- ❌ Don't parse SSE as regular JSON (it's line-by-line `data:` prefixed)
- ❌ Don't ignore `[DONE]` marker in streaming responses

## iMessage Extension
- ❌ Don't try to access APIs unavailable in extension sandbox
- ❌ Don't block main thread with network calls
- ❌ Don't forget to handle compact vs expanded presentation styles

## SwiftUI
- ❌ Don't forget `@MainActor` for UI updates
- ❌ Don't use UIKit patterns when SwiftUI equivalents exist

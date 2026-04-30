# WardrobeAI

WardrobeAI is a SwiftUI wardrobe app with a built-in mock AI stylist. It helps you catalog clothing pieces, track favorites, mark items as worn, and generate outfit combinations by occasion and season.

## What is included

- SwiftUI desktop app built as a Swift Package so you can open `Package.swift` directly in Xcode.
- Persistent closet storage in Application Support using JSON.
- AI-ready styling layer via the `AIStyling` protocol and a `MockAIStylist` implementation.
- Sample wardrobe data so the app feels complete on first launch.

## Run it

1. Open `/Users/nandhasankar/Documents/New project/Package.swift` in Xcode.
2. Select the `WardrobeAI` executable target.
3. Run on macOS.

## Upgrade the AI later

Replace `MockAIStylist` in `/Users/nandhasankar/Documents/New project/Sources/WardrobeAI/AIStylist.swift` with a live service that sends the closet inventory and styling prompt to your preferred model API, then maps the response back into `OutfitRecommendation`.

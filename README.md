# Nora

A calm, native personal-brief app for iOS — SwiftUI, iOS 18+, Swift 6.

## Run it

1. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you don't have it:
   ```
   brew install xcodegen
   ```
2. From the project root, generate the Xcode project (the `.xcodeproj` isn't checked in on purpose — `project.yml` is the source of truth):
   ```
   cd nora-ios
   xcodegen generate
   ```
3. Open `Nora.xcodeproj` in Xcode 16+.
4. Select the `Nora` scheme and an iOS 18 simulator (e.g. iPhone 16).
5. Build and run (`Cmd+R`).

The app runs fully offline: all services (`Domain/Services`) have in-memory mock implementations seeded with realistic sample data (`Shared/PreviewData`), and persistence (`UserProfile`, `Topic`, saved `Insight`) is backed by SwiftData on-device.

## Explore in previews

Every screen has SwiftUI previews (light/dark, empty, loading, error, large Dynamic Type) — open any file under `Features/` in the canvas to iterate without running the simulator.

## Tests

Swift Testing specs live in `NoraTests/`. Run with `Cmd+U` in Xcode, or:
```
xcodebuild test -scheme Nora -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Project structure

```
Nora/
  App/                  Entry point, DI container, navigation router, tab shell
  Core/
    DesignSystem/        Colors, typography, spacing, radius, buttons, modifiers
    Persistence/          SwiftData entities + model container
    Utilities/            Haptics, date formatting
  Domain/
    Models/                UserProfile, Topic, Insight, Brief, ConversationMessage
    Services/               Protocol + mock implementation per service
    Repositories/           SwiftData bridges for Views/Stores
  Features/
    Onboarding/ Today/ Assistant/ Following/ TopicDetail/ Profile/ Settings/
  Shared/
    Components/            InsightRowView, EmptyStateView, ErrorStateView, etc.
    PreviewData/            Sample persona used by mocks and previews
NoraTests/                Swift Testing unit tests
project.yml                XcodeGen project spec
```

---
name: simulator-verify
description: Verify implementations by building, running, and screenshotting the iOS simulator. Supports deep links and touch interactions via idb.
---

# Simulator Verification Skill

## Purpose
Build the app, run it in simulator, navigate to specific screens, interact with UI, and take screenshots for visual verification.

## When Auto-Activated
- Keywords: verify, screenshot, simulator, test build, check ui, visual check

## Prerequisites
- idb installed: `brew tap facebook/fb && brew install idb-companion && pip3 install fb-idb`

---

## Quick Commands

### Boot & Build
```bash
# Boot simulator
xcrun simctl boot "iPhone 16" && open -a Simulator

# Build (incremental is fast)
xcodebuild build -workspace Anytype.xcworkspace -scheme Anytype \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath ./DerivedData

# Install & launch
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/Anytype.app
xcrun simctl launch booted io.anytype.app
```

### Navigation (Deep Links)
```bash
xcrun simctl openurl booted "anytype://create-object-widget"
xcrun simctl openurl booted "anytype://object?objectId=xxx&spaceId=yyy"
xcrun simctl openurl booted "anytype://sharing-extension"
xcrun simctl openurl booted "anytype://membership?tier=1"
```

### Touch Interactions (idb)
```bash
idb ui tap 200 400           # Tap at coordinates
idb ui swipe 200 600 200 200 # Swipe up
idb ui text "Hello World"    # Type text
idb ui button HOME           # Press home button
idb ui describe-all          # Get accessibility tree (JSON)
idb ui describe-point 200 400 # Get element at coordinates
```

### Screenshot
```bash
xcrun simctl io booted screenshot /tmp/verify.png
# Then read /tmp/verify.png with Claude's Read tool
```

---

## Anytype Constants

| Constant | Value |
|----------|-------|
| Bundle ID | `io.anytype.app` |
| App Path | `./DerivedData/Build/Products/Debug-iphonesimulator/Anytype.app` |
| Workspace | `Anytype.xcworkspace` |
| Scheme | `Anytype` |

---

## Deep Links Reference

### URL Schemes
| Scheme | Build |
|--------|-------|
| `anytype://` | All builds |
| `dev-anytype://` | Debug only |
| `prod-anytype://` | Production only |

### Available Routes

| Route | URL | Purpose |
|-------|-----|---------|
| Create object | `anytype://create-object-widget` | New object from widget |
| Share extension | `anytype://sharing-extension` | Show share sheet |
| Gallery import | `anytype://main/import?type=1&source=2` | Import from gallery |
| Space invite | `anytype://invite?cid=<cid>&key=<key>` | Join space |
| Open object | `anytype://object?objectId=<id>&spaceId=<spaceId>` | Navigate to object |
| Profile | `anytype://hi?id=<id>&key=<key>` | Open identity page |
| Membership | `anytype://membership?tier=1` | Membership tier |

---

## Command Reference

### simctl Commands (Simulator Management)
| Command | Description |
|---------|-------------|
| `xcrun simctl list devices available` | List all simulators with UDIDs |
| `xcrun simctl boot <UDID>` | Start simulator |
| `xcrun simctl shutdown <UDID>` | Stop simulator |
| `xcrun simctl install booted <app_path>` | Install .app |
| `xcrun simctl launch booted <bundle_id>` | Launch app |
| `xcrun simctl terminate booted <bundle_id>` | Close app |
| `xcrun simctl io booted screenshot <path>` | Capture screen |
| `xcrun simctl openurl booted <url>` | Open deep link |

### idb Commands (UI Interaction)
| Command | Description |
|---------|-------------|
| `idb ui tap X Y` | Tap at coordinates |
| `idb ui swipe X1 Y1 X2 Y2` | Swipe gesture |
| `idb ui text "hello"` | Type text |
| `idb ui button HOME` | Press hardware button |
| `idb ui describe-all` | Get accessibility tree (JSON) |
| `idb ui describe-point X Y` | Get element at point |

---

## Workflow

```
┌─────────────────────┐
│ 1. BUILD            │  xcodebuild build ...
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 2. BOOT & INSTALL   │  simctl boot + install
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 3. LAUNCH APP       │  simctl launch
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 4. NAVIGATE         │  Deep link OR idb tap/swipe
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 5. INTERACT         │  idb tap/type/swipe
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 6. SCREENSHOT       │  simctl screenshot
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│ 7. ANALYZE          │  Claude reads image
└─────────────────────┘
```

---

## Finding UI Elements

### Option A: Accessibility Tree
```bash
idb ui describe-all > /tmp/ui-tree.json
# Parse JSON to find element coordinates
```

### Option B: Screenshot + Vision
```bash
xcrun simctl io booted screenshot /tmp/screen.png
# Claude analyzes image to identify element positions
```

---

## Example Session

```bash
# 1. Boot simulator
xcrun simctl boot "iPhone 16"
open -a Simulator

# 2. Build (skip if already built)
xcodebuild build -workspace Anytype.xcworkspace -scheme Anytype \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath ./DerivedData

# 3. Install & launch
xcrun simctl install booted ./DerivedData/Build/Products/Debug-iphonesimulator/Anytype.app
xcrun simctl launch booted io.anytype.app

# 4. Navigate to specific screen (deep link)
xcrun simctl openurl booted "anytype://create-object-widget"

# 5. Wait for animation
sleep 2

# 6. Tap on a button (example: 200,400)
idb ui tap 200 400

# 7. Type some text
idb ui text "Hello World"

# 8. Screenshot
xcrun simctl io booted screenshot /tmp/verify.png

# 9. Claude reads and analyzes
```

---

## Related Files
- `Modules/DeepLinks/Sources/DeepLinks/DeepLink.swift` - Route definitions
- `Modules/DeepLinks/Sources/DeepLinks/DeepLinkParser.swift` - URL parsing
- `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift` - Navigation handling

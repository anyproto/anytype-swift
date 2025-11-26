# Analytics Developer (Smart Router)

## Purpose
Context-aware routing to the Anytype iOS analytics system. Helps you add analytics events, track user routes, and maintain consistent analytics patterns.

## When Auto-Activated
- Working with analytics events or AnytypeAnalytics
- Adding route tracking or event properties
- Modifying `AnalyticsConstants.swift` or `AnytypeAnalytics+Events.swift`
- Keywords: analytics, route tracking, logEvent, AnytypeAnalytics, AnalyticsConstants

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **ALWAYS define route enums in AnalyticsConstants.swift** - Never hardcode route strings
2. **ALWAYS use existing property keys** - Use `AnalyticsEventsPropertiesKey.*`
3. **NEVER use string literals for routes** - Use typed enums with `.rawValue`
4. **ALWAYS use `.compactMapValues { $0 }` for optional properties** - Removes nil values
5. **ALWAYS track route context** - Know how users reached a feature

## 📋 Quick Workflow

### Adding New Analytics Event

1. **Define route enum** (if needed): Add to `AnalyticsConstants.swift`
2. **Add event method**: Add to `AnytypeAnalytics+Events.swift`
3. **Use in code**: Call `AnytypeAnalytics.instance().logYourEvent(...)`

### Adding Route Tracking to Existing Screen

1. **Define route enum**: Add `YourFeatureRoute` to `AnalyticsConstants.swift`
2. **Update data model**: Add `route: YourFeatureRoute?` parameter
3. **Pass through hierarchy**: Coordinator → View → ViewModel
4. **Update analytics call**: Pass route to existing log method

## 🎯 Common Patterns

### Pattern 1: Screen Analytics (onAppear)

```swift
// ViewModel
final class HomeWidgetsViewModel {
    let route: HomeWidgetRoute?

    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget(route: route)
    }
}

// Analytics method (AnytypeAnalytics+Events.swift)
func logScreenWidget(route: HomeWidgetRoute?) {
    logEvent("ScreenWidget", withEventProperties: [
        AnalyticsEventsPropertiesKey.route: route?.rawValue
    ].compactMapValues { $0 })
}

// Route enum (AnalyticsConstants.swift)
enum HomeWidgetRoute: String, Hashable, Codable {
    case home = "Home"
    case space = "Space"
    case appLaunch = "AppLaunch"
}
```

### Pattern 2: Button Click Analytics

```swift
// ViewModel
func onTapShare() {
    AnytypeAnalytics.instance().logClickShare(type: .link, route: .settings)
    output?.onShareSelected()
}

// Analytics method
func logClickShare(type: ShareType, route: ShareRoute) {
    logEvent("ClickShare", withEventProperties: [
        AnalyticsEventsPropertiesKey.type: type.rawValue,
        AnalyticsEventsPropertiesKey.route: route.rawValue
    ])
}
```

### Pattern 3: Multi-Space Events

```swift
func logCreateObject(objectType: AnalyticsObjectType, spaceId: String, route: AnalyticsEventsRouteKind) {
    logEvent("CreateObject", spaceId: spaceId, withEventProperties: [
        AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
        AnalyticsEventsPropertiesKey.route: route.rawValue
    ])
}
```

## 🗂️ Analytics File Structure

### Key Files
- **AnalyticsConstants.swift** - All route enums, property keys (400+ lines)
- **AnytypeAnalytics+Events.swift** - All event methods (1,500+ lines)
- **Converters/** - Domain type → analytics value converters

### Route Enum Location

**Always add to AnalyticsConstants.swift**, grouped by feature:

```swift
// Widget-related routes
enum AnalyticsWidgetRoute: String {
    case addWidget = "AddWidget"
    case inner = "Inner"
}

enum HomeWidgetRoute: String, Hashable, Codable {
    case home = "Home"
    case space = "Space"
    case appLaunch = "AppLaunch"
}

// Screen navigation routes
enum SettingsSpaceShareRoute: String {
    case settings = "Settings"
    case navigation = "Navigation"
    case chat = "Chat"
}
```

## 📈 Route Tracking Implementation

### Step-by-Step: Adding Route to Screen

**Example: Adding route tracking to ScreenWidget**

1. **Define route enum** (AnalyticsConstants.swift):
```swift
enum HomeWidgetRoute: String, Hashable, Codable {
    case home = "Home"            // Home button click
    case space = "Space"          // Space selection
    case appLaunch = "AppLaunch"  // App launch
}
```

2. **Update data model**:
```swift
struct HomeWidgetData: Hashable {
    let spaceId: String
    let route: HomeWidgetRoute?  // Add route parameter
}
```

3. **Pass through view hierarchy**:
```swift
// Coordinator
HomeWidgetsView(info: info, output: model, route: data.route)

// View
HomeWidgetsViewModel(info: info, output: output, route: route)
```

4. **Update analytics call**:
```swift
// ViewModel
func onAppear() {
    AnytypeAnalytics.instance().logScreenWidget(route: route)
}

// Analytics method
func logScreenWidget(route: HomeWidgetRoute?) {
    logEvent("ScreenWidget", withEventProperties: [
        AnalyticsEventsPropertiesKey.route: route?.rawValue
    ].compactMapValues { $0 })
}
```

5. **Set route at navigation points**:
```swift
// Home button
let data = HomeWidgetData(spaceId: spaceId, route: .home)

// Space selection
let data = HomeWidgetData(spaceId: spaceId, route: .space)

// App launch
let data = HomeWidgetData(spaceId: spaceId, route: .appLaunch)
```

## 🔧 Common Property Keys

Located in `AnalyticsEventsPropertiesKey`:

| Key | Usage | Example |
|-----|-------|---------|
| `route` | Navigation context | `.home`, `.navigation`, `.widget` |
| `type` | Primary classification | `.image`, `.video`, `.file` |
| `objectType` | Object type ID | `type.analyticsType.analyticsId` |
| `spaceId` | Space identifier | `document.spaceId` |
| `count` | Quantity values | Number of items |
| `format` | Data format | File format, date format |

## ⚠️ Common Mistakes

### ❌ Hardcoded Route Strings
```swift
// WRONG
AnytypeAnalytics.instance().logScreenWidget(route: "Home")

// CORRECT
AnytypeAnalytics.instance().logScreenWidget(route: .home)
```

### ❌ Route Enum in Wrong File
```swift
// WRONG - defined in feature file
enum HomeWidgetRoute: String {
    case home = "Home"
}

// CORRECT - defined in AnalyticsConstants.swift
```

### ❌ Missing compactMapValues
```swift
// WRONG - will include nil values as NSNull
[AnalyticsEventsPropertiesKey.route: route?.rawValue]

// CORRECT - removes nil values
[AnalyticsEventsPropertiesKey.route: route?.rawValue].compactMapValues { $0 }
```

### ❌ Using String Literals for Property Keys
```swift
// WRONG
["route": route.rawValue]

// CORRECT
[AnalyticsEventsPropertiesKey.route: route.rawValue]
```

## 🔍 Finding Existing Patterns

```bash
# Search for existing events
rg "logEvent.*EventName" Anytype/Sources/Analytics/

# Find route enums
rg "enum.*Route.*String" Anytype/Sources/Analytics/AnalyticsConstants.swift

# Find property usage
rg "AnalyticsEventsPropertiesKey\." Anytype/Sources/Analytics/

# Find screen analytics
rg "func logScreen" Anytype/Sources/Analytics/AnytypeAnalytics+Events.swift
```

## 📚 Complete Documentation

**Full Guide**: `Anytype/Sources/PresentationLayer/Common/Analytics/ANALYTICS_PATTERNS.md`

For comprehensive coverage of:
- Analytics system architecture
- All analytics patterns (user actions, screen navigation, content creation)
- Route context tracking best practices
- Platform-specific considerations
- Testing analytics events
- Migration patterns for adding parameters
- Complete examples and code snippets

## ✅ Workflow Checklist

When adding analytics:

- [ ] Route enum added to `AnalyticsConstants.swift`
- [ ] Event method added to `AnytypeAnalytics+Events.swift`
- [ ] Used existing property keys (`AnalyticsEventsPropertiesKey.*`)
- [ ] Optional properties use `.compactMapValues { $0 }`
- [ ] Route passed through view hierarchy (if tracking navigation)
- [ ] No hardcoded strings for routes or property keys
- [ ] Followed existing naming conventions (PascalCase events, camelCase properties)

## 🔗 Related Skills & Docs

- **ios-dev-guidelines** → `IOS_DEVELOPMENT_GUIDE.md` - MVVM/Coordinator patterns for passing analytics data
- **code-generation-developer** → Understanding the build system
- **design-system-developer** → Tracking UI interactions

---

**Navigation**: This is a smart router. For deep patterns and examples, always refer to `ANALYTICS_PATTERNS.md`.

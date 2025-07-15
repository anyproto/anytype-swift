# Analytics Patterns in Anytype iOS

*Last updated: 2025-07-15*

This document provides comprehensive patterns and guidelines for working with analytics in the Anytype iOS application.

## 🏗️ Analytics System Overview

### Core Components
- **Main Analytics File**: `AnytypeAnalytics+Events.swift` (1,500+ lines of event methods)
- **Constants File**: `AnalyticsConstants.swift` (enums, property keys, route definitions)
- **Analytics Provider**: Uses Amplitude for event tracking
- **Event Pattern**: `logEvent(eventName, properties)` with structured property dictionaries

### Key Files
```
Anytype/Sources/Analytics/
├── AnytypeAnalytics/
│   ├── AnytypeAnalytics.swift              # Core analytics class
│   └── AnytypeAnalytics+Events.swift       # All analytics event methods
└── AnalyticsConstants.swift                # Property keys, enums, routes
```

## 📊 Analytics Event Patterns

### Standard Event Structure
```swift
func logEventName(parameters...) {
    logEvent(
        "EventName",
        spaceId: spaceId,                    // Optional: for space-specific events
        withEventProperties: [
            AnalyticsEventsPropertiesKey.type: value.rawValue,
            AnalyticsEventsPropertiesKey.route: route.rawValue,
            // ... other properties
        ]
    )
}
```

### Common Property Keys
Located in `AnalyticsEventsPropertiesKey`:
- `type` - Primary classification (e.g., "image", "video", "file")
- `route` - Context/source (e.g., "Camera", "Gallery", "Navigation")
- `spaceId` - Space identifier for multi-space events
- `objectType` - Object type classification
- `count` - Quantity/number values
- `format` - Data format information

### Event Naming Convention
- **PascalCase**: `CreateObject`, `UploadMedia`, `ChangeLayout`
- **Action-focused**: Use verbs that describe user actions
- **Consistent**: Follow existing patterns in the codebase

## 🔧 Adding New Analytics Events

### Step 1: Add Analytics Function
```swift
// In AnytypeAnalytics+Events.swift
func logYourNewEvent(type: YourEnum, spaceId: String, route: YourRoute? = nil) {
    logEvent(
        "YourNewEvent",
        spaceId: spaceId,
        withEventProperties: [
            AnalyticsEventsPropertiesKey.type: type.rawValue,
            AnalyticsEventsPropertiesKey.route: route?.rawValue
        ].compactMapValues { $0 }
    )
}
```

### Step 2: Add Supporting Enums (if needed)
```swift
// In AnalyticsConstants.swift
enum YourEventRoute: String {
    case contextA = "ContextA"
    case contextB = "ContextB"
    case contextC = "ContextC"
}
```

### Step 3: Use in Code
```swift
// In your feature code
AnytypeAnalytics.instance().logYourNewEvent(
    type: .someType,
    spaceId: document.spaceId,
    route: .contextA
)
```

## 🎯 Common Analytics Patterns

### 1. User Actions
```swift
// Button clicks, menu selections
func logClickSettingsButton() {
    logEvent("ClickSettingsButton")
}

func logSelectObjectType(_ type: AnalyticsObjectType, route: SelectObjectTypeRoute) {
    logEvent("SelectObjectType", withEventProperties: [
        AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
        AnalyticsEventsPropertiesKey.route: route.rawValue
    ])
}
```

### 2. Screen Navigation
```swift
// Screen views
func logScreenSettings() {
    logEvent("ScreenSettings")
}

func logScreenObject(type: AnalyticsObjectType, layout: DetailsLayout, spaceId: String) {
    logEvent("ScreenObject", spaceId: spaceId, withEventProperties: [
        AnalyticsEventsPropertiesKey.objectType: type.analyticsId,
        AnalyticsEventsPropertiesKey.layout: layout.rawValue
    ])
}
```

### 3. Content Creation
```swift
// Object/block creation
func logCreateObject(objectType: AnalyticsObjectType, spaceId: String, route: AnalyticsEventsRouteKind) {
    logEvent("CreateObject", spaceId: spaceId, withEventProperties: [
        AnalyticsEventsPropertiesKey.objectType: objectType.analyticsId,
        AnalyticsEventsPropertiesKey.route: route.rawValue
    ])
}
```

### 4. Route Context Tracking
```swift
// Track how users reached a feature
enum FeatureRoute: String {
    case navigation = "Navigation"
    case search = "Search"
    case widget = "Widget"
    case keyboard = "Keyboard"
}
```

## 📈 Analytics Best Practices

### 1. Property Consistency
- Use existing property keys when possible
- Follow established enum patterns
- Use `.compactMapValues { $0 }` for optional properties

### 2. Route Tracking
- Always track how users reached a feature
- Use descriptive route names
- Keep route enums focused and specific

### 3. Space Context
- Include `spaceId` for multi-space features
- Use space-specific analytics for workspace features

### 4. Enum Usage
- Create typed enums for analytics values
- Use `.rawValue` for string conversion
- Implement `.analyticsId` for complex types

## 🔍 Common Analytics Enums

### Object Types
```swift
enum AnalyticsObjectType {
    case object(typeId: String)
    case file(fileExt: String)
    case custom
    
    var analyticsId: String { /* implementation */ }
}
```

### Route Classifications
```swift
enum AnalyticsEventsRouteKind: String {
    case navigation = "Navigation"
    case search = "Search"
    case widget = "Widget"
    case clipboard = "Clipboard"
    case sharingExtension = "SharingExtension"
}
```

### Chat/Communication
```swift
enum ChatAttachmentType: String {
    case object = "Object"
    case photo = "Photo"
    case file = "File"
    case camera = "Camera"
}
```

## 📱 Platform-Specific Considerations

### iOS-Specific Events
- Camera/photo picker interactions
- Document scanner usage
- File system access
- Share sheet interactions

### Example: Media Upload Context
```swift
enum UploadMediaRoute: String {
    case camera = "Camera"           // Camera capture
    case scan = "Scan"              // Document scanner
    case filePicker = "FilePicker"  // File picker
}
```

## 🛠️ Testing Analytics

### In Development
- Use debug builds to verify event firing
- Check Amplitude dashboard for event receipt
- Validate property values and types

### Analytics Validation
```swift
// Example of structured analytics call
AnytypeAnalytics.instance().logUploadMedia(
    type: .image,
    spaceId: document.spaceId,
    route: .camera
)
```

## 🔄 Migration Patterns

### Adding Optional Parameters
```swift
// Old function
func logExistingEvent(type: SomeType, spaceId: String) { ... }

// New function with optional route
func logExistingEvent(type: SomeType, spaceId: String, route: SomeRoute? = nil) {
    var properties = [AnalyticsEventsPropertiesKey.type: type.rawValue]
    if let route = route {
        properties[AnalyticsEventsPropertiesKey.route] = route.rawValue
    }
    logEvent("ExistingEvent", spaceId: spaceId, withEventProperties: properties)
}
```

## 📋 Quick Reference

### Finding Analytics Events
```bash
# Search for existing events
rg "logEvent.*EventName" Anytype/Sources/Analytics/

# Find property usage
rg "AnalyticsEventsPropertiesKey\." Anytype/Sources/Analytics/

# Search for route enums
rg "Route.*String" Anytype/Sources/Analytics/AnalyticsConstants.swift
```

### Common Commands
```swift
// Basic event
AnytypeAnalytics.instance().logEventName()

// Event with properties
AnytypeAnalytics.instance().logEventName(type: .value, route: .context)

// Space-specific event
AnytypeAnalytics.instance().logEventName(spaceId: spaceId, type: .value)
```

This guide provides the foundation for working with analytics in the Anytype iOS app. Always follow existing patterns and use the established property keys and enum structures.
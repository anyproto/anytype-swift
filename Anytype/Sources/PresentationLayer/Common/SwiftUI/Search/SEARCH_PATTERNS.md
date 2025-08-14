# Search Patterns in Anytype iOS

*Last updated: 2025-07-14*

This document outlines the common search implementation patterns used throughout the Anytype iOS application.

## Primary Pattern: SearchBar Component

### Location
`/Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/Common/SearchView/SearchBar.swift`

### Description
The main reusable search component used throughout the app. Provides consistent styling and behavior.

### Features
- Binding to search text
- Auto-focus capability
- Search icon on left (magnifying glass)
- Clear button (X) on right when text exists
- Rounded background with consistent design system colors
- Optional bottom divider
- Uses either `AnytypeTextField` or `AutofocusedTextField`

### Usage
```swift
SearchBar(
    text: $searchText,
    focused: false,  // true for auto-focus behavior
    placeholder: Loc.search,  // or custom placeholder
    shouldShowDivider: true   // false to hide bottom divider
)
```

### Styling
- Background: `Color.Background.highlightedMedium`
- Corner radius: 10pt
- Padding: 8pt internal, 25pt horizontal for icon space
- Search icon: `.X18.search` asset
- Clear icon: `.multiplyCircleFill` asset

## SearchView Component

### Location
`/Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/Common/SearchView/SearchView.swift`

### Description
Full search experience component that includes SearchBar plus results display.

### Features
- Contains SearchBar
- Manages search results display
- Empty state handling
- Section support for organizing results
- Built-in loading states

### Usage
```swift
SearchView(
    searchText: $searchText,
    searchResults: searchResults,
    emptyStateView: { EmptySearchView() },
    resultCell: { result in
        SearchResultCell(result: result)
    }
)
```

## Inline Search Pattern

### Description
For simpler search implementations that don't require the full SearchBar component.

### Example (from DebugMenuView)
```swift
HStack {
    Image(systemName: "magnifyingglass")
        .foregroundColor(.Text.secondary)
    
    TextField(Loc.search, text: $searchText)
        .textFieldStyle(PlainTextFieldStyle())
        .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
        .foregroundColor(.Text.primary)
    
    if !searchText.isEmpty {
        Button {
            searchText = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.Text.secondary)
        }
    }
}
.padding(.horizontal, 12)
.padding(.vertical, 8)
.background(Color.Background.secondary)
.cornerRadius(10)
```

## Async Search Implementation

### Pattern
Use `.task(id:)` modifier for reactive search that responds to text changes.

### Example
```swift
SearchBar(text: $searchText, focused: false)
    .task(id: searchText) {
        await viewModel.performSearch(query: searchText)
    }
```

### In ViewModel
```swift
@Published var searchText: String = ""
@Published var searchResults: [SearchResult] = []

func performSearch(query: String) async {
    guard !query.isEmpty else {
        searchResults = []
        return
    }
    
    // Debounce search to avoid excessive API calls
    try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
    
    // Perform actual search
    searchResults = await searchService.search(query: query)
}
```

## Local Filtering Pattern

### Description
For filtering local data without async operations.

### Example
```swift
@Published var searchText: String = ""
@Published var allItems: [Item] = []

var filteredItems: [Item] {
    guard !searchText.isEmpty else { return allItems }
    return allItems.filter { item in
        item.name.localizedCaseInsensitiveContains(searchText)
    }
}
```

## Best Practices

### Localization
- Always use `Loc.search` for "Search" placeholder
- Use `Loc.search.ellipsis` for "Search..." placeholder (if available)
- Never hardcode search-related strings

### Performance
- Use debouncing for API searches (300ms recommended)
- For local filtering, use computed properties
- Consider pagination for large result sets

### UX Guidelines
- Always show clear button when text exists
- Provide empty state messaging
- Maintain search state during navigation when appropriate
- Use case-insensitive matching for user-friendly search

### Design System Compliance
- Use design system colors and fonts
- Follow spacing guidelines (8pt internal padding)
- Use approved icon assets (X18.search, multiplyCircleFill)

## Related Components

### SearchCell
Location: `/Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/Common/SearchView/Cell/SearchCell.swift`
- Standard cell for displaying search results
- Supports various content types

### Global Search Components
Location: `/Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/GlobalSearch/`
- Specialized components for app-wide search functionality
- More complex search with metadata and filtering

### Object Search Components
Location: `/Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/ObjectSearch/`
- Components for searching within objects
- Type-specific search implementations
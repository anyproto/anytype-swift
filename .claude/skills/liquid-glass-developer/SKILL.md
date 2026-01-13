# Liquid Glass Developer (iOS 26)

## Purpose
Context-aware routing to iOS 26 Liquid Glass implementation patterns. Proper use of GlassEffectContainer, glassEffect modifiers, morphing transitions, and interactive effects.

## When Auto-Activated
- Working with glass effects or iOS 26 visual effects
- Keywords: glass, liquid glass, glassEffect, GlassEffectContainer, iOS 26, morphing
- Editing files with glass effect modifiers
- Implementing navigation panels, floating buttons, or translucent UI

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **ALWAYS group glass elements in `GlassEffectContainerIOS26`** - Glass elements must be grouped for unified composition
2. **ALWAYS use `glassEffectIDIOS26` for morphing** - Elements that appear/disappear need IDs for smooth transitions
3. **Glass defines its shape** - Use `glassEffect(in: Shape)`, no separate `clipShape()` needed
4. **Glass is for navigation layer only** - Never apply to content, only floating controls
5. **Use interactive glass for buttons** - Buttons should use `.regular.interactive()` for touch feedback

## 📋 Quick Reference

### Available Utilities (View+iOS26.swift)

```swift
// Wrapper for GlassEffectContainer with iOS version check
GlassEffectContainerIOS26(spacing: 20) {
    // Glass elements here
}

// Interactive glass effect (scaling/bounce on touch)
.glassEffectInteractiveIOS26(in: Circle())
.glassEffectInteractiveIOS26(in: .rect(cornerRadius: 16))

// Standard glass effect (no touch feedback)
.glassEffectIOS26(in: Circle())

// Morphing transition ID
.glassEffectIDIOS26("buttonId", in: glassNamespace)

// Glass button style (legacy, prefer glassEffectInteractiveIOS26)
.buttonStyleGlassIOS26()
```

### Complete Pattern Example

```swift
struct NavigationPanel: View {
    @Namespace private var glassNamespace
    @State private var isExpanded = false

    var body: some View {
        GlassEffectContainerIOS26(spacing: 20) {
            HStack {
                Button { } label: {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 40, height: 40)
                }
                .glassEffectInteractiveIOS26(in: Circle())
                .glassEffectIDIOS26("search", in: glassNamespace)

                if isExpanded {
                    Button { } label: {
                        Image(systemName: "plus")
                            .frame(width: 40, height: 40)
                    }
                    .glassEffectInteractiveIOS26(in: Circle())
                    .glassEffectIDIOS26("add", in: glassNamespace)
                }
            }
        }
        .animation(.bouncy, value: isExpanded)
    }
}
```

### Glass Shapes

```swift
// Circular buttons
.glassEffectInteractiveIOS26(in: Circle())

// Rounded rectangle
.glassEffectInteractiveIOS26(in: .rect(cornerRadius: 16))

// Capsule
.glassEffectInteractiveIOS26(in: Capsule())
```

## 🔄 Morphing Transitions

For smooth state transitions between glass elements:

```swift
@Namespace private var glassNamespace

// Elements with same container + IDs morph smoothly
GlassEffectContainerIOS26 {
    if editing {
        plusButton
            .glassEffectIDIOS26("leftButton", in: glassNamespace)
    } else {
        burgerButton
            .glassEffectIDIOS26("leftButton", in: glassNamespace)
    }
}
.animation(.bouncy, value: editing)
```

**Key requirements:**
1. Elements in same `GlassEffectContainerIOS26`
2. Each element has `glassEffectIDIOS26` with shared namespace
3. Wrap state changes with animation

## ⚠️ Common Mistakes

### No Container Grouping

```swift
// ❌ WRONG - Individual glass effects
HStack {
    button1.glassEffectIOS26(in: Circle())
    button2.glassEffectIOS26(in: Circle())
}

// ✅ CORRECT - Grouped in container
GlassEffectContainerIOS26 {
    HStack {
        button1.glassEffectInteractiveIOS26(in: Circle())
        button2.glassEffectInteractiveIOS26(in: Circle())
    }
}
```

### Redundant clipShape

```swift
// ❌ WRONG - clipShape before glass
.clipShape(Circle())
.glassEffectIOS26(in: Circle())

// ✅ CORRECT - Glass defines shape
.glassEffectInteractiveIOS26(in: Circle())
```

### Missing Morphing IDs

```swift
// ❌ WRONG - Abrupt appear/disappear
if isVisible {
    button.glassEffectInteractiveIOS26(in: Circle())
}

// ✅ CORRECT - Smooth morphing
if isVisible {
    button
        .glassEffectInteractiveIOS26(in: Circle())
        .glassEffectIDIOS26("button", in: namespace)
}
```

### Glass on Content

```swift
// ❌ WRONG - Glass on content
Text("Hello World")
    .glassEffectIOS26(in: .rect(cornerRadius: 8))

// ✅ CORRECT - Glass only on floating controls
// Use standard backgrounds for content:
Text("Hello World")
    .background(Color.Background.primary)
```

## 📚 iOS Version Handling

All utilities handle iOS version checks internally:
- **iOS 26+**: Native glass effects applied
- **iOS < 26**: Fallback to `Color.Background.navigationPanel + .ultraThinMaterial`

```swift
// This works on all iOS versions
.glassEffectInteractiveIOS26(in: Circle())

// Equivalent to:
if #available(iOS 26.0, *) {
    self.glassEffect(.regular.interactive(), in: Circle())
} else {
    self
        .background(Color.Background.navigationPanel)
        .background(.ultraThinMaterial)
}
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `View+iOS26.swift` | Glass effect utilities and wrappers |
| `HomeBottomNavigationPanelView.swift` | Navigation panel with glass buttons |
| `ChatInput.swift` | Chat input with morphing burger/plus button |
| `ChatActionPanel.swift` | Action buttons with interactive glass |

## 🔗 External Resources

- [Understanding GlassEffectContainer - DEV](https://dev.to/arshtechpro/understanding-glasseffectcontainer-in-ios-26-2n8p)
- [GlassEffectContainer - Apple Docs](https://developer.apple.com/documentation/swiftui/glasseffectcontainer/)
- [iOS 26 Liquid Glass Reference](https://github.com/conorluddy/LiquidGlassReference)
- [WWDC25: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)

## ✅ Implementation Checklist

- [ ] Glass elements wrapped in `GlassEffectContainerIOS26`
- [ ] Buttons use `glassEffectInteractiveIOS26` (not just `glassEffectIOS26`)
- [ ] State-dependent elements have `glassEffectIDIOS26` for morphing
- [ ] No redundant `clipShape()` before glass effects
- [ ] Glass only on navigation/floating controls, not content
- [ ] Animation wrapper for state changes (`withAnimation(.bouncy)` or `.animation()`)
- [ ] Tested on iOS 26 simulator for glass appearance
- [ ] Tested on iOS 18 simulator for fallback behavior

## 🔗 Related Skills

- **design-system-developer** → Icons and colors used in glass buttons
- **ios-dev-guidelines** → SwiftUI patterns and view modifiers

---

**Navigation**: This skill covers iOS 26 Liquid Glass patterns. For implementation details, see `View+iOS26.swift`.

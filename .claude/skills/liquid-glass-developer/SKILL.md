---
name: liquid-glass-developer
description: Context-aware routing to iOS 26 Liquid Glass implementation patterns. Use when working with glass effects, GlassEffectContainer, morphing transitions, or iOS 26 visual effects.
---

# Liquid Glass Developer (iOS 26)

## Purpose
Context-aware routing to iOS 26 Liquid Glass implementation patterns. Proper use of GlassEffectContainer, glassEffect modifiers, morphing transitions, and interactive effects.

## When Auto-Activated
- Working with glass effects or iOS 26 visual effects
- Keywords: glass, liquid glass, glassEffect, GlassEffectContainer, iOS 26, morphing, UIGlassEffect, UIVisualEffectView, cornerConfiguration, GlassContainerViewIOS26, GlassEffectViewIOS26
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

## 🔧 UIKit Implementation

### Available Utilities (UIView+iOS26Glass.swift)

```swift
// Container for grouping glass elements (like GlassEffectContainerIOS26 in SwiftUI)
let container = GlassContainerViewIOS26(spacing: 12)
container.glassContentView.addSubview(yourContent)

// Individual glass effect view (always interactive)
let glassView = GlassEffectViewIOS26()
glassView.glassContentView.addSubview(yourButton)

// Glass button configuration
let config = UIButton.Configuration.glassIOS26()
let button = UIButton(configuration: config)
```

### UIKit Pattern Example

```swift
final class NavigationBarView: UIView {
    private let glassContainer = GlassContainerViewIOS26(spacing: 12)
    private let buttonGlass = GlassEffectViewIOS26()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        // Add container to view
        addSubview(glassContainer) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            $0.height.equal(to: 44)
        }

        // Setup circular button with glass
        buttonGlass.applyCircleShape(diameter: 44)
        buttonGlass.layoutUsing.anchors {
            $0.size(CGSize(width: 44, height: 44))
        }

        // Add button to glass content view (NOT directly to buttonGlass)
        buttonGlass.glassContentView.addSubview(myButton) {
            $0.center(in: buttonGlass.glassContentView)
        }

        // Add glass button to container's content view
        glassContainer.glassContentView.addSubview(buttonGlass)
    }
}
```

### Shape Methods

```swift
// Circular buttons (44x44)
glassView.applyCircleShape(diameter: 44)

// Capsule/pill shape (e.g., for title views)
glassView.applyCapsuleShape(height: 44)

// iOS 26+: Uses cornerConfiguration = .capsule()
// iOS < 26: Uses layer.cornerRadius fallback
```

### UIKit Critical Rules

1. **Always add content to `glassContentView`** - Never add subviews directly to the glass view
   ```swift
   // ❌ WRONG
   glassView.addSubview(button)

   // ✅ CORRECT
   glassView.glassContentView.addSubview(button)
   ```

2. **Call shape methods once in setup** - Not in `layoutSubviews` (unless height changes dynamically)
   ```swift
   // ❌ WRONG - Called every layout pass
   override func layoutSubviews() {
       super.layoutSubviews()
       glassView.applyCapsuleShape(height: bounds.height)
   }

   // ✅ CORRECT - Called once with fixed height
   func setup() {
       glassView.applyCapsuleShape(height: 44)
   }
   ```

3. **GlassEffectViewIOS26 is always interactive** - No property to set, touch feedback is built-in

4. **Use glassIOS26() for text buttons**
   ```swift
   var config = UIButton.Configuration.glassIOS26()
   config.title = "Done"
   config.baseForegroundColor = .Control.accent100
   let button = UIButton(configuration: config)
   ```

### iOS Version Handling (UIKit)

```swift
// GlassEffectViewIOS26 handles version checks internally:
// iOS 26+: UIGlassEffect with cornerConfiguration
// iOS < 26: UIBlurEffect(style: .systemUltraThinMaterial) + Background.navigationPanel

// Example of internal implementation:
private func setupGlassEffect() {
    if #available(iOS 26.0, *) {
        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = true
        let effectView = UIVisualEffectView(effect: glassEffect)
        addSubview(effectView)
        glassEffectView = effectView
    } else {
        backgroundColor = .Background.navigationPanel
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        addSubview(blurView)
    }
}
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `View+iOS26.swift` | SwiftUI glass effect utilities and wrappers |
| `UIView+iOS26Glass.swift` | **UIKit glass effect utilities** |
| `HomeBottomNavigationPanelView.swift` | Navigation panel with glass buttons |
| `ChatInput.swift` | Chat input with morphing burger/plus button |
| `ChatActionPanel.swift` | Action buttons with interactive glass |
| `EditorNavigationBarView.swift` | **UIKit navigation bar with glass container** |
| `EditorNavigationBarTitleView.swift` | **UIKit title view with capsule glass** |

## 🔗 External Resources

- [Understanding GlassEffectContainer - DEV](https://dev.to/arshtechpro/understanding-glasseffectcontainer-in-ios-26-2n8p)
- [GlassEffectContainer - Apple Docs](https://developer.apple.com/documentation/swiftui/glasseffectcontainer/)
- [iOS 26 Liquid Glass Reference](https://github.com/conorluddy/LiquidGlassReference)
- [WWDC25: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)

## ✅ Implementation Checklist

### SwiftUI
- [ ] Glass elements wrapped in `GlassEffectContainerIOS26`
- [ ] Buttons use `glassEffectInteractiveIOS26` (not just `glassEffectIOS26`)
- [ ] State-dependent elements have `glassEffectIDIOS26` for morphing
- [ ] No redundant `clipShape()` before glass effects
- [ ] Glass only on navigation/floating controls, not content
- [ ] Animation wrapper for state changes (`withAnimation(.bouncy)` or `.animation()`)

### UIKit
- [ ] Glass elements wrapped in `GlassContainerViewIOS26`
- [ ] Content added to `glassContentView` (not directly to glass view)
- [ ] Shape methods called once in setup (not `layoutSubviews`)
- [ ] Text buttons use `UIButton.Configuration.glassIOS26()`
- [ ] Circular buttons use `applyCircleShape(diameter:)`
- [ ] Pill/capsule shapes use `applyCapsuleShape(height:)`

### Testing
- [ ] Tested on iOS 26 simulator for glass appearance
- [ ] Tested on iOS 18 simulator for fallback behavior

## 🔗 Related Skills

- **design-system-developer** → Icons and colors used in glass buttons
- **ios-dev-guidelines** → SwiftUI patterns and view modifiers

---

**Navigation**: This skill covers iOS 26 Liquid Glass patterns. For implementation details, see `View+iOS26.swift`.

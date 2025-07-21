# Color System Documentation

## Overview

Anytype uses a code-generated color system based on asset catalogs. Colors are defined in `.xcassets` files and automatically converted to Swift code using SwiftGen.

## Color Asset Structure

### Location
Colors are organized in two main asset catalogs:
- **System Colors**: `/Modules/Assets/Sources/Assets/Resources/SystemColors.xcassets`
- **Component Colors**: `/Modules/Assets/Sources/Assets/Resources/ComponentColors.xcassets`

### Organization
```
SystemColors.xcassets/
└── DesignSystem/
    ├── Control/
    │   ├── button.colorset/
    │   ├── active.colorset/
    │   ├── inactive.colorset/
    │   ├── accent25.colorset/
    │   ├── accent50.colorset/
    │   ├── accent80.colorset/
    │   ├── accent100.colorset/
    │   ├── accent125.colorset/
    │   ├── transparentActive.colorset/
    │   ├── transparentInactive.colorset/
    │   └── white.colorset/
    ├── Background/
    ├── Shape/
    ├── Text/
    └── VeryLight/
```

## Code Generation

### Process
1. Colors are defined in `.xcassets` files with light/dark variants
2. SwiftGen reads these assets during build
3. Generated code provides type-safe access to colors

### Running Code Generation
```bash
make generate
```

This command runs SwiftGen and updates all generated color accessors.

### Generated Code Location
- SwiftUI colors: `Color+Generated.swift`
- UIKit colors: `UIColor+Generated.swift`

## Usage

### SwiftUI
```swift
import Assets

// Control colors
Color.Control.button      // Previously: Control/Button
Color.Control.active      // Previously: Control/Active  
Color.Control.inactive    // Previously: Control/Inactive

// Other examples
Color.Background.primary
Color.Text.primary
Color.Shape.primary
```

### UIKit
```swift
import Assets

// Control colors
UIColor.Control.button
UIColor.Control.active
UIColor.Control.inactive
```

## Color Naming Conventions

### Control Colors
- **button** → Primary control color (was Control/Button)
- **active** → Secondary control state (was Control/Active)
- **inactive** → Tertiary/disabled state (was Control/Inactive)
- **accent[XX]** → Accent color variations with opacity
- **transparent[State]** → Transparent variants

### Naming Rules
1. Use lowercase for color names in assets
2. Use descriptive names that indicate purpose, not appearance
3. Include state variations (active, inactive, hover, pressed)
4. Group related colors in subdirectories

## Renaming Colors

### ⚠️ IMPORTANT: Never rename colors directly in code!

To rename a color:

1. **Update the asset name** in the `.xcassets` file:
   - Open the `.xcassets` file in Xcode
   - Select the color set to rename
   - Change the name in the file inspector
   - Update `Contents.json` if editing manually

2. **Run code generation**:
   ```bash
   make generate
   ```

3. **Update all usages** in the codebase:
   - The compiler will show errors for old names
   - Use global find & replace for systematic updates
   - Example: `Color.Control.button` → `Color.Control.primary`

### Example: Renaming Control Colors

If renaming Control colors as requested:
- `Control/Button` → `Control/Primary`
- `Control/Active` → `Control/Secondary`
- `Control/Inactive` → `Control/Tertiary`

Steps:
1. In SystemColors.xcassets:
   - Rename `button.colorset` → `primary.colorset`
   - Rename `active.colorset` → `secondary.colorset`
   - Rename `inactive.colorset` → `tertiary.colorset`

2. Run: `make generate`

3. Update code:
   ```swift
   // Before
   Color.Control.button
   Color.Control.active
   Color.Control.inactive
   
   // After
   Color.Control.primary
   Color.Control.secondary
   Color.Control.tertiary
   ```

## Dark Mode Support

Each color set contains variants for:
- Light appearance
- Dark appearance
- High contrast variants (if needed)

Example `Contents.json`:
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0x25",
          "green" : "0x25",
          "red" : "0x25"
        }
      },
      "idiom" : "universal",
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "light"
        }
      ]
    },
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0xF3",
          "green" : "0xF3",
          "red" : "0xF3"
        }
      },
      "idiom" : "universal",
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ]
    }
  ]
}
```

## Common Pitfalls

1. **Don't edit generated files** - Changes will be lost on next generation
2. **Don't use string-based color names** - Use the type-safe accessors
3. **Always run `make generate`** after changing assets
4. **Test in both light and dark modes** after color changes
5. **Update all usages** - Use compiler errors as a guide

## Related Documentation

- See `DESIGN_SYSTEM_MAPPING.md` for component styling
- See `Assets/Templates/swiftgen.yml` for generation configuration
- See Apple's documentation on Asset Catalogs for advanced features
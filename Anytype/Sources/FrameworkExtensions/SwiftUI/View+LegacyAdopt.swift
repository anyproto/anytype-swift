import Foundation
import SwiftUI

/// Adopt for ios 14

@available(iOS, deprecated: 15)
enum LegacyMaterial {
    /// A material that's somewhat translucent.
    case regularMaterial

    /// A material that's more opaque than translucent.
    case thickMaterial

    /// A material that's more translucent than opaque.
    case thinMaterial

    /// A mostly translucent material.
    case ultraThinMaterial

    /// A mostly opaque material.
    case ultraThickMaterial
}

@available(iOS, deprecated: 15)
extension View {
    // Replace to .background(.LegacyMaterial) from ios 15
    func backgroundMaterial(_ style: LegacyMaterial) -> some View {
        if #available(iOS 15.0, *) {
            switch style {
            case .regularMaterial:
                return self.background(.regularMaterial).eraseToAnyView()
            case .thickMaterial:
                return self.background(.thickMaterial).eraseToAnyView()
            case .thinMaterial:
                return self.background(.thinMaterial).eraseToAnyView()
            case .ultraThinMaterial:
                return self.background(.ultraThinMaterial).eraseToAnyView()
            case .ultraThickMaterial:
                return self.background(.ultraThickMaterial).eraseToAnyView()
            }
        } else {
            return self.eraseToAnyView()
        }
    }
}

@available(iOS, deprecated: 15)
enum LegacyVerticalEdge {
    
    /// The top edge.
    case top
    
    /// The bottom edge.
    case bottom
    
    @available(iOS 15.0, *)
    func toSystemInset() -> VerticalEdge {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
    
    func toSystemAlignment() -> Alignment {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}

@available(iOS, deprecated: 15)
extension View {
    func safeAreaInsetLegacy<V>(
        edge: LegacyVerticalEdge,
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) -> some View where V : View {
        if #available(iOS 15.0, *) {
            return self.safeAreaInset(
                edge: edge.toSystemInset(),
                alignment: alignment,
                spacing: spacing,
                content: content
            ).eraseToAnyView()
        } else {
            return self.overlay(content(), alignment: edge.toSystemAlignment()).eraseToAnyView()
        }
    }
}

@available(iOS, deprecated: 15)
enum ContentShapeKindsLegacy {
    case interaction
    case dragPreview
    case contextMenuPreview
    case hoverEffect
    
    @available(iOS 15.0, *)
    func toiOSKind() -> ContentShapeKinds {
        switch self {
        case .interaction:
            return .interaction
        case .dragPreview:
            return .dragPreview
        case .contextMenuPreview:
            return .contextMenuPreview
        case .hoverEffect:
            return .hoverEffect
        }
    }
}

@available(iOS, deprecated: 15)
extension View {
    func contentShapeLegacy<S>(_ kind: ContentShapeKindsLegacy, _ shape: S, eoFill: Bool = false) -> some View where S : Shape {
        if #available(iOS 15.0, *) {
            return self.contentShape(kind.toiOSKind(), shape, eoFill: eoFill)
        } else {
            return self
        }
    }
}

@available(iOS, deprecated: 16)
extension View {
    func hideScrollIndicatorLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollIndicators(.never)
        } else {
            return self
        }
    }
    
    func hideKeyboardOnScrollLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollDismissesKeyboard(.immediately)
        } else {
            return self
        }
    }
}

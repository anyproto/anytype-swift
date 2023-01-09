import Foundation
import SwiftUI

/// Adopt for ios 14

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
}

extension View {
    
    // Replace to .safeAreaInset(...) from ios 15
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
            return self.overlay(content(), alignment: .bottom).eraseToAnyView()
        }
    }
}

import SwiftUI
import AnytypeCore

@available(iOS, deprecated: 26.0)
extension View {
    @ViewBuilder
    nonisolated public func navigationZoomTransition(sourceID: String, in namespace: Namespace.ID) -> some View {
        if #available(iOS 26.0, *) {
            self.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
    
    @ViewBuilder
    nonisolated public func scrollEdgeEffectStyleIOS26(_ style: ScrollEdgeEffectStyleIOS26?, for edges: Edge.Set) -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(style?.style, for: edges)
        } else {
            self
        }
    }
    
    @ViewBuilder
    public func buttonStyleCircleGlassIOS26() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
                .buttonBorderShape(.circle)
        } else {
            self
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
    
    @ViewBuilder
    public func glassEffectIOS26(in shape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: shape)
        } else {
            self
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
        }
    }

    @ViewBuilder
    public func glassEffectInteractiveIOS26(in shape: some Shape) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: shape)
        } else {
            self
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
                .clipShape(shape)
        }
    }

    @ViewBuilder
    public func glassEffectIDIOS26<ID: Hashable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffectID(id, in: namespace)
        } else {
            self
        }
    }

    @ViewBuilder
    public func toolbarNavigationBarOpaqueBackgroundLegacy() -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            self
                .toolbarBackground(Color.Background.primary, for: .navigationBar)
        }
    }

    @ViewBuilder
    public func matchedTransitionSourceIOS26<ID: Hashable>(id: ID, in namespace: Namespace.ID?) -> some View {
        if let namespace, #available(iOS 26.0, *), FeatureFlags.matchedTransitionSource {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
}

@available(iOS, deprecated: 26.0)
public struct GlassEffectContainerIOS26<Content: View>: View {
    let spacing: CGFloat?
    @ViewBuilder let content: () -> Content

    public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            if let spacing {
                GlassEffectContainer(spacing: spacing) { content() }
            } else {
                GlassEffectContainer { content() }
            }
        } else {
            content()
        }
    }
}

public enum ScrollEdgeEffectStyleIOS26 {
    case automatic
    case hard
    case soft
}

@available(iOS 26.0, *)
public extension ScrollEdgeEffectStyleIOS26 {
    var style: ScrollEdgeEffectStyle {
        switch self {
        case .automatic:
                .automatic
        case .hard:
                .hard
        case .soft:
                .soft
        }
    }
}

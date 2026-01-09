import SwiftUI

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
    public func buttonStyleGlassIOS26() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
                .background(Color.Background.navigationPanel)
                .background(.ultraThinMaterial)
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

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

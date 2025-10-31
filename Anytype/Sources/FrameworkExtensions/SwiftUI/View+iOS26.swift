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
}

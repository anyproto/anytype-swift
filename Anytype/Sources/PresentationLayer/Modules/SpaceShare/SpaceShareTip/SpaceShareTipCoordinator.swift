import Foundation
import SwiftUI

@available(iOS 17.0, *)
private struct SpaceShareTipCoordinator: ViewModifier {
    
    private let tip = SpaceShareTip()
    
    @Environment(\.keyboardDismiss) private var keyboardDismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    @State private var showView = false
    
    func body(content: Content) -> some View {
        content
            .task {
                for await shouldDisplay in tip.shouldDisplayUpdates {
                    if shouldDisplay {
                        await dismissAllPresented()
                    }
                    showView = shouldDisplay
                }
            }
            .sheet(isPresented: $showView) {
                SpaceShareTipView()
            }
    }
}

extension View {
    func handleSpaceShareTip() -> some View {
        if #available(iOS 17.0, *) {
            return self.modifier(SpaceShareTipCoordinator())
        } else {
            return self
        }
    }
}

import Foundation
import SwiftUI
import TipKit

struct TipCustomViewPresentationModifier<TipType: Tip, Screen: View>: ViewModifier {
    
    let tip: TipType
    let view: () -> Screen
    
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
                view()
            }
    }
}

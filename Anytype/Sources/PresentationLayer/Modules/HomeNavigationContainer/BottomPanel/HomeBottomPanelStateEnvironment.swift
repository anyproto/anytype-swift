import Foundation
import SwiftUI

private extension EnvironmentValues {
    @Entry var homeBottomPanelState = Binding.constant(HomeBottomPanelState())
}

private struct HomeBottomHiddenStateViewModifier: ViewModifier {
 
    struct State: Equatable {
        let hidden: Bool
        let animated: Bool
    }
    
    let state: State

    @Environment(\.homeBottomPanelState) @Binding private var homeBottomPanelState
    @Environment(\.anytypeNavigationItemData) private var itemData
    
    func body(content: Content) -> some View {
        if let itemData {
            content
                .onAppear {
                    if state.animated == false {
                        homeBottomPanelState.setHidden(state.hidden, for: itemData)
                    } else {
                        withAnimation {
                            homeBottomPanelState.setHidden(state.hidden, for: itemData)
                        }
                    }
                }
                .onChange(of: state) { _, newValue in
                    if newValue.animated == false {
                        homeBottomPanelState.setHidden(newValue.hidden, for: itemData)
                    } else {
                        withAnimation {
                            homeBottomPanelState.setHidden(newValue.hidden, for: itemData)
                        }
                    }
                }
        } else {
            content
        }
    }
}


// A transient overlay's claim on the panel (the search overlay). The plain
// modifier is a latch that would outlive the overlay - this one remembers the
// screen's own latched value while `hidden` is on and hands it back when it
// flips off. Instant both ways: the overlay's own fade is the only animation.
private struct HomeBottomHiddenOverlayViewModifier: ViewModifier {

    let hidden: Bool

    @Environment(\.homeBottomPanelState) @Binding private var homeBottomPanelState
    @Environment(\.anytypeNavigationItemData) private var itemData
    @State private var previousHidden: Bool?

    func body(content: Content) -> some View {
        content
            .onChange(of: hidden) { _, newValue in
                guard let itemData else { return }
                if newValue {
                    // Open: the panel fades out under the appearing overlay
                    previousHidden = homeBottomPanelState.hidden(for: itemData)
                    withAnimation {
                        homeBottomPanelState.setHidden(true, for: itemData)
                    }
                } else {
                    // Close: back instantly - the overlay's fade-out reveals a
                    // panel already in place, not one fading in after
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        homeBottomPanelState.setHidden(previousHidden ?? false, for: itemData)
                    }
                }
            }
    }
}

extension View {
    
    func homeBottomPanelState(_ handler: Binding<HomeBottomPanelState>) -> some View {
        environment(\.homeBottomPanelState, handler)
    }
    
    func homeBottomPanelOverlayHidden(_ hidden: Bool) -> some View {
        modifier(HomeBottomHiddenOverlayViewModifier(hidden: hidden))
    }
    
    func homeBottomPanelHidden(_ hidden: Bool, animated: Bool = true) -> some View {
        modifier(HomeBottomHiddenStateViewModifier(state: HomeBottomHiddenStateViewModifier.State(hidden: hidden, animated: animated)))
    }
}

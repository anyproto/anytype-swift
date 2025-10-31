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


extension View {
    
    func homeBottomPanelState(_ handler: Binding<HomeBottomPanelState>) -> some View {
        environment(\.homeBottomPanelState, handler)
    }
    
    func homeBottomPanelHidden(_ hidden: Bool, animated: Bool = true) -> some View {
        modifier(HomeBottomHiddenStateViewModifier(state: HomeBottomHiddenStateViewModifier.State(hidden: hidden, animated: animated)))
    }
}

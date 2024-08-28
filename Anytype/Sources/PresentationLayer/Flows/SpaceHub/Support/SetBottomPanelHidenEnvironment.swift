import Foundation
import SwiftUI

private struct SetHomeBottomPanelHidden: EnvironmentKey {
    static let defaultValue = Binding.constant(true)
}

private extension EnvironmentValues {
    var setHomeBottomPanelHidden: Binding<Bool> {
        get { self[SetHomeBottomPanelHidden.self] }
        set { self[SetHomeBottomPanelHidden.self] = newValue }
    }
}

private struct SetBottomViewModifier: ViewModifier {
 
    struct State: Equatable {
        let hidden: Bool
        let animated: Bool
    }
    
    let state: State

    @Environment(\.setHomeBottomPanelHidden) @Binding private var setBottomPanelHidden
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if state.animated == false {
                    setBottomPanelHidden = state.hidden
                } else {
                    withAnimation {
                        setBottomPanelHidden = state.hidden
                    }
                }
            }
            .onChange(of: state, perform: { newValue in
                if newValue.animated == false {
                    setBottomPanelHidden = newValue.hidden
                } else {
                    withAnimation {
                        setBottomPanelHidden = newValue.hidden
                    }
                }
            })
    }
}


extension View {
    
    func setHomeBottomPanelHiddenHandler(_ handler: Binding<Bool>) -> some View {
        environment(\.setHomeBottomPanelHidden, handler)
    }
    
    func homeBottomPanelHidden(_ hidden: Bool, animated: Bool = true) -> some View {
        modifier(SetBottomViewModifier(state: .init(hidden: hidden, animated: animated)))
    }
}

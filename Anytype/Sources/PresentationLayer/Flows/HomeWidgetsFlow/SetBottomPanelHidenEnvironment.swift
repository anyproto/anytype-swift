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
    
    let hidden: Bool
    let animated: Bool
    @Environment(\.setHomeBottomPanelHidden) @Binding private var setBottomPanelHidden
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if animated == false {
                    setBottomPanelHidden = hidden
                } else {
                    withAnimation {
                        setBottomPanelHidden = hidden
                    }
                }
            }
            .onChange(of: hidden, perform: { newValue in
                if animated == false {
                    setBottomPanelHidden = newValue
                } else {
                    withAnimation {
                        setBottomPanelHidden = newValue
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
        modifier(SetBottomViewModifier(hidden: hidden, animated: animated))
    }
}

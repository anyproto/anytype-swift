import Foundation
import SwiftUI

private struct SetHomeBottomPanelHidden: EnvironmentKey {
    static let defaultValue: (Bool) -> Void = { _ in }
}

private extension EnvironmentValues {
    var setHomeBottomPanelHidden: (Bool) -> Void {
        get { self[SetHomeBottomPanelHidden.self] }
        set { self[SetHomeBottomPanelHidden.self] = newValue }
    }
}

private struct SetBottomViewModifier: ViewModifier {
    
    let hidden: Bool
    @Environment(\.setHomeBottomPanelHidden) private var setBottomPanelHidden
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setBottomPanelHidden(hidden)
            }
            .onChange(of: hidden, perform: { newValue in
                setBottomPanelHidden(newValue)
            })
    }
}


extension View {
    
    func setHomeBottomPanelHiddenHandler(_ handler: @escaping (Bool) -> Void) -> some View {
        environment(\.setHomeBottomPanelHidden, handler)
    }
    
    func homeBottomPanelHidden(_ hidden: Bool) -> some View {
        modifier(SetBottomViewModifier(hidden: hidden))
    }
}

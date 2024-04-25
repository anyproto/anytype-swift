import Foundation
import SwiftUI

struct StandardButtonGroupDisableKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var standardButtonGroupDisable: Binding<Bool> {
        get { self[StandardButtonGroupDisableKey.self] }
        set { self[StandardButtonGroupDisableKey.self] = newValue }
    }
}

struct AsyncStandardButtonGroup<Content: View>: View {
    
    @State private var buttonGroupDisable = false
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.standardButtonGroupDisable, $buttonGroupDisable)
    }
}

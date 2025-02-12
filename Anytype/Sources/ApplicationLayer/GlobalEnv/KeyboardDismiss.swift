import Foundation
import SwiftUI

struct KeyboardDismiss {
    
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func callAsFunction() {
        window?.endEditing(true)
    }
}

extension EnvironmentValues {
    @Entry var keyboardDismiss = KeyboardDismiss(window: nil)
}

extension View {
    func setKeyboardDismissEnv(window: UIWindow?) -> some View {
        environment(\.keyboardDismiss, KeyboardDismiss(window: window))
    }
}

import Foundation
import SwiftUI

struct KeyboardDismiss: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var keyboardDismiss: () -> Void {
        get { self[KeyboardDismiss.self] }
        set { self[KeyboardDismiss.self] = newValue }
    }
}

extension View {
    func setKeyboardDismissEnv(window: UIWindow?) -> some View {
        environment(\.keyboardDismiss, { [weak window] in
            window?.resignFirstResponder()
        })
    }
}

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var keyboardDismiss: () -> Void = {}
}

extension View {
    func setKeyboardDismissEnv(window: UIWindow?) -> some View {
        environment(\.keyboardDismiss, { [weak window] in
            window?.endEditing(true)
        })
    }
}

import Foundation
import SwiftUI

struct KeyboardDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var notificationDismiss: () -> Void {
        get { self[KeyboardDismissKey.self] }
        set { self[KeyboardDismissKey.self] = newValue }
    }
}

import Foundation
import SwiftUI

struct NotificationDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var notificationDismiss: () -> Void {
        get { self[NotificationDismissKey.self] }
        set { self[NotificationDismissKey.self] = newValue }
    }
}

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var notificationDismiss: () -> Void = {}
}

import UIKit

extension Notification.Name {
    static let DeviceDidShaked: Self = .init("AnyType.Events.Motion.DeviceDidShaked")
}

class MainWindow: UIWindow {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if let event = event, event.type == .motion, event.subtype == .motionShake {
            NotificationCenter.default.post(name: .DeviceDidShaked, object: nil)
        }
    }
}

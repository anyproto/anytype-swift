import UIKit
import SwiftEntryKit

@MainActor
public struct ToastManager {
    
    public static func show(message: String) {
        let attributedString = NSAttributedString(
            string: message,
            attributes: ToastAttributes.defaultAttributes
        )
        show(message: attributedString)
    }
    
    public static func show(message: NSAttributedString) {
        let attributedMessage = NSMutableAttributedString(attributedString: message)
        
        let toastView = ToastView(frame: .zero)
        toastView.setMessage(attributedMessage)
        
        var attributes = EKAttributes()
        attributes.windowLevel = .alerts
        attributes.entranceAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.exitAnimation = .init(fade: EKAttributes.Animation.RangeAnimation(from: 0, to: 1, duration: 0.4))
        attributes.positionConstraints.size = .init(width: .offset(value: 16), height: .intrinsic)
        attributes.position = .top
        attributes.roundCorners = .all(radius: 8)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        attributes.precedence = .enqueue(priority: .normal)
        
        SwiftEntryKit.display(entry: toastView, using: attributes)
    }
    
    public static func dismiss(completion: @escaping () -> Void) {
        SwiftEntryKit.dismiss(.all, with: completion)
    }
}

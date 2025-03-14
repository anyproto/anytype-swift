import Foundation
import UIKit

struct KeyboardEvent {
    let animationDuration: TimeInterval?
    let animationCurve: UIView.AnimationOptions?
    let beginFrame: CGRect?
    let endFrame: CGRect?
    
    @MainActor
    init?(withUserInfo userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo else {
            return nil
        }
        guard let isLocal = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber, isLocal.boolValue else {
            return nil
        }
        animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        animationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt)
            .map { UIView.AnimationOptions(rawValue: $0) }
        beginFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    @MainActor
    func animate(_ animation: @escaping () -> Void) {
        guard let animationDuration, let animationCurve else {
            animation()
            return
        }
        let animationOptions = UIView.AnimationOptions(rawValue: animationCurve.rawValue << 16)
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: animationOptions,
            animations: animation
        )
    }
}

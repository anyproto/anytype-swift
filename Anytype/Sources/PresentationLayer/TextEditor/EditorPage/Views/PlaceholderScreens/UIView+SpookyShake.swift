import UIKit

extension UIView {
    func spookyShake() {
        move()
        scale()
    }
    
    func move() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 10
        animation.values = [-1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -5, 5, -5, 5, -4, 4, -3, 3, -2, 2, -1, 1]
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: nil)
    }
    
    func scale() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.2, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 1.5
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: nil)
    }
}


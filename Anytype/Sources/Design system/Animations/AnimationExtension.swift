import SwiftUI

extension Animation {
    static let ripple = Animation.spring(dampingFraction: 0.5).speed(1.2)
    static let smoothScroll = Animation.easeOut.speed(3)
    static let fastSpring = Animation.spring(response: 0.3, dampingFraction: 1, blendDuration: 0)
}

import SwiftUI

extension Animation {
    static let ripple = Animation.spring(dampingFraction: 0.5).speed(1.2)
    static let smoothScroll = Animation.easeOut.speed(3)
}

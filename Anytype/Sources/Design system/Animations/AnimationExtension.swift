import SwiftUI

extension Animation {
    static let smoothScroll = Animation.easeOut.speed(3)
    static let fastSpring = Animation.spring(response: 0.3, dampingFraction: 1, blendDuration: 0)
    static let slowIteractiveSpring = Animation.interactiveSpring(response: 0.3, dampingFraction: 1)
}

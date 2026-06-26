import SwiftUI

extension Animation {
    static let smoothScroll = Animation.easeOut.speed(3)
    static let fastSpring = Animation.spring(response: 0.3, dampingFraction: 1, blendDuration: 0)
    static let slowIteractiveSpring = Animation.interactiveSpring(response: 0.3, dampingFraction: 1)
    static let disclosure = Animation.snappy(duration: 0.28, extraBounce: 0.05)
    static let disclosureSmall = Animation.snappy(duration: 0.22)
    static let widgetTile = Animation.spring(response: 0.4, dampingFraction: 0.85)
}

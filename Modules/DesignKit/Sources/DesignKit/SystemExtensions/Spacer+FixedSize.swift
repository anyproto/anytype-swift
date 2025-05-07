import SwiftUI

public extension Spacer {
    static func fixedWidth(_ width: CGFloat) -> some View {
        Spacer().frame(width: width)
    }
    
    static func fixedHeight(_ height: CGFloat) -> some View {
        Spacer().frame(height: height)
    }
}

import SwiftUI

extension Spacer {
    static func fixedWidth(_ width: CGFloat) -> some View {
        Spacer().frame(width: width)
    }
    
    static func minWidth(_ width: CGFloat) -> some View {
        Spacer().frame(minWidth: width)
    }
    
    static func fixedHeight(_ height: CGFloat) -> some View {
        Spacer().frame(height: height)
    }
}

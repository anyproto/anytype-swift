import SwiftUI

public extension View {
    func border(_ radius: CGFloat, color: Color, lineWidth: CGFloat = 1) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(color, lineWidth: lineWidth)
        )
    }

    func outerBorder(_ radius: CGFloat, color: Color, lineWidth: CGFloat = 1) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(color, lineWidth: lineWidth).padding(-lineWidth)
        )
    }
}

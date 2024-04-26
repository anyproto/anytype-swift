import SwiftUI

struct LineProgressBarConfiguration {
    let height: CGFloat
    let cornerRadius: CGFloat
    let innerCornerRadius: CGFloat?
    let foregroundColor: Color
    let innerForegroundColor: Color
    
    static let fileStorage = LineProgressBarConfiguration(
        height: 6,
        cornerRadius: 3,
        innerCornerRadius: nil,
        foregroundColor: .Shape.secondary,
        innerForegroundColor: .Text.primary
    )
}

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
        foregroundColor: .Stroke.secondary,
        innerForegroundColor: .Text.primary
    )
    
    static let joinFlow = LineProgressBarConfiguration(
        height: 2,
        cornerRadius: 30,
        innerCornerRadius: 30,
        foregroundColor: .Stroke.primary,
        innerForegroundColor: .Button.button
    )
}

import SwiftUI

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=3681%3A1219
extension Color {
    static let textPrimary = Color(ColorName.textPrimary)
    static let textSecondary = Color(ColorName.textSecondary)
    static let textTertiary = Color(ColorName.textTertiary)
    
    static let background = Color(ColorName.grayscaleWhite)
    
    static let divider = Color(ColorName.divider)
    static let dividerSecondary = Color(ColorName.dividerSecondary)

    static let stroke = Color(ColorName.stroke)
    
    // MARK: - Mapping
    static let buttonPrimary = pureAmber
    static let buttonPrimartText = white
    
    static let buttonSecondary = white
    static let buttonSecondaryBorder = stroke
    static let buttonSecondaryText = textPrimary
    
    static let buttonActive = Color(ColorName.grayscale50)
    static let buttonInactive = Color(ColorName.buttonInactive)
    static let buttonSelected = Color(ColorName.buttonSelected)
    
    static let toastBackground = Color("toastBackground")
    
    // MARK: - Color palette
    static let pureAmber = Color(ColorName.pureAmber)
    static let pureRed = Color(ColorName.pureRed)
    static let pureBlue = Color(ColorName.pureBlue)
    static let lightBlue = Color(ColorName.lightBlue)
    static let darkBlue = Color(ColorName.darkBlue)
    
    static let grayscale10 = Color(ColorName.grayscale10)
    static let grayscale30 = Color(ColorName.grayscale30)
    static let grayscale50 = Color(ColorName.grayscale50)
    static let grayscaleWhite = Color(ColorName.grayscaleWhite)
}

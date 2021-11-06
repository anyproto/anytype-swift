import SwiftUI

// https://www.figma.com/file/TupCOWb8sC9NcjtSToWIkS/Android---main---draft?node-id=3681%3A1219
extension Color {
    
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
    
    static let grayscale10 = Color(ColorName.grayscale10)
    static let grayscale30 = Color(ColorName.grayscale30)
    static let grayscale50 = Color(ColorName.grayscale50)
    static let grayscaleWhite = Color(ColorName.grayscaleWhite)
}

extension Color: AnytypeColorProtocol {
    
    // MARK: - Pure colors

    static let pureLemon: Color = AnytypeColor.pureLemon.asColor
    static let pureAmber: Color = AnytypeColor.pureAmber.asColor
    static let pureRed: Color = AnytypeColor.pureRed.asColor
    static let purePink: Color = AnytypeColor.purePink.asColor
    static let purePurple: Color = AnytypeColor.purePurple.asColor
    static let pureUltramarine: Color =  AnytypeColor.pureUltramarine.asColor
    static let pureBlue: Color = AnytypeColor.pureBlue.asColor
    static let pureTeal: Color = AnytypeColor.pureTeal.asColor
    static let pureGreen: Color = AnytypeColor.pureGreen.asColor
    
    // MARK: - Dark colors
    
    static let darkLemon: Color = AnytypeColor.darkLemon.asColor
    static let darkAmber: Color = AnytypeColor.darkAmber.asColor
    static let darkRed: Color = AnytypeColor.darkRed.asColor
    static let darkPink: Color =  AnytypeColor.darkPink.asColor
    static let darkPurple: Color =  AnytypeColor.darkPurple.asColor
    static let darkUltramarine: Color = AnytypeColor.darkUltramarine.asColor
    static let darkBlue: Color = AnytypeColor.darkBlue.asColor
    static let darkTeal: Color = AnytypeColor.darkTeal.asColor
    static let darkGreen: Color = AnytypeColor.darkGreen.asColor
    static let darkColdGray: Color =  AnytypeColor.darkColdGray.asColor
    
    
    // MARK: - Light colors
    
    static let lightLemon: Color = AnytypeColor.lightLemon.asColor
    static let lightAmber: Color = AnytypeColor.lightAmber.asColor
    static let lightRed: Color = AnytypeColor.lightRed.asColor
    static let lightPink: Color = AnytypeColor.lightPink.asColor
    static let lightPurple: Color =  AnytypeColor.lightPurple.asColor
    static let lightUltramarine: Color = AnytypeColor.lightUltramarine.asColor
    static let lightBlue = AnytypeColor.lightBlue.asColor
    static let lightTeal: Color = AnytypeColor.lightTeal.asColor
    static let lightGreen: Color = AnytypeColor.lightGreen.asColor
    static let lightColdGray: Color = AnytypeColor.lightColdGray.asColor
    
    // MARK: - Text colors
    
    static let textPrimary: Color = AnytypeColor.textPrimary.asColor
    static let textSecondary: Color = AnytypeColor.textSecondary.asColor
    static let textTertiary: Color = AnytypeColor.textTertiary.asColor
    
}

import UIKit
import AnytypeCore

extension UIColor {
    static var highlighterColor: UIColor {
        .init(red: 255.0/255.0, green: 181.0/255.0, blue: 34.0/255.0, alpha: 1)
    }
    
    static let stroke = color(name: ColorName.stroke)
    
    static let divider = color(name: ColorName.divider)
    static let dividerSecondary = color(name: ColorName.dividerSecondary)
    
    static let buttonActive = color(name: ColorName.grayscale50)
    static let buttonInactive = color(name: ColorName.buttonInactive)
    static let buttonSelected = color(name: ColorName.buttonSelected)
    
    // MARK: - Color palette
    
    static let grayscale90 = color(name: ColorName.grayscale90)
    static let grayscale70 = color(name: ColorName.grayscale70)
    static let grayscale50 = color(name: ColorName.grayscale50)
    static let grayscale30 = color(name: ColorName.grayscale30)
    static let grayscale10 = color(name: ColorName.grayscale10)

    // MARK: - Color for background

    static let backgroundPrimary = color(name: ColorName.grayscaleWhite)

    static var selected: UIColor {
        .init(hexString: "#867D42", alpha: 0.1)
    }
    
    /// Color that can be used in case if we couldn't parse color from middleware
    static let defaultColor = grayscale90
    
    private static func color(name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            anytypeAssertionFailure("No color named: \(name)")
            return defaultColor
        }
        
        return color
    }
}

extension UIColor: AnytypeColorProtocol {
    
    // MARK: - Pure colors

    static let pureLemon: UIColor = AnytypeColor.pureLemon.asUIColor
    static let pureAmber: UIColor = AnytypeColor.pureAmber.asUIColor
    static let pureRed: UIColor = AnytypeColor.pureRed.asUIColor
    static let purePink: UIColor = AnytypeColor.purePink.asUIColor
    static let purePurple: UIColor = AnytypeColor.purePurple.asUIColor
    static let pureUltramarine: UIColor =  AnytypeColor.pureUltramarine.asUIColor
    static let pureBlue: UIColor = AnytypeColor.pureBlue.asUIColor
    static let pureTeal: UIColor = AnytypeColor.pureTeal.asUIColor
    static let pureGreen: UIColor = AnytypeColor.pureGreen.asUIColor
    
    // MARK: - Dark colors
    
    static let darkLemon: UIColor = AnytypeColor.darkLemon.asUIColor
    static let darkAmber: UIColor = AnytypeColor.darkAmber.asUIColor
    static let darkRed: UIColor = AnytypeColor.darkRed.asUIColor
    static let darkPink: UIColor =  AnytypeColor.darkPink.asUIColor
    static let darkPurple: UIColor =  AnytypeColor.darkPurple.asUIColor
    static let darkUltramarine: UIColor = AnytypeColor.darkUltramarine.asUIColor
    static let darkBlue: UIColor = AnytypeColor.darkBlue.asUIColor
    static let darkTeal: UIColor = AnytypeColor.darkTeal.asUIColor
    static let darkGreen: UIColor = AnytypeColor.darkGreen.asUIColor
    static let darkColdGray: UIColor =  AnytypeColor.darkColdGray.asUIColor
    
    
    // MARK: - Light colors
    
    static let lightLemon: UIColor = AnytypeColor.lightLemon.asUIColor
    static let lightAmber: UIColor = AnytypeColor.lightAmber.asUIColor
    static let lightRed: UIColor = AnytypeColor.lightRed.asUIColor
    static let lightPink: UIColor = AnytypeColor.lightPink.asUIColor
    static let lightPurple: UIColor =  AnytypeColor.lightPurple.asUIColor
    static let lightUltramarine: UIColor = AnytypeColor.lightUltramarine.asUIColor
    static let lightBlue: UIColor = AnytypeColor.lightBlue.asUIColor
    static let lightTeal: UIColor = AnytypeColor.lightTeal.asUIColor
    static let lightGreen: UIColor = AnytypeColor.lightGreen.asUIColor
    static let lightColdGray: UIColor = AnytypeColor.lightColdGray.asUIColor
    
    // MARK: - Text colors
    
    static let textPrimary: UIColor = AnytypeColor.textPrimary.asUIColor
    static let textSecondary: UIColor = AnytypeColor.textSecondary.asUIColor
    static let textTertiary: UIColor = AnytypeColor.textTertiary.asUIColor
    
}

import UIKit
import AnytypeCore

extension UIColor {
    static var highlighterColor: UIColor {
        .init(red: 255.0/255.0, green: 181.0/255.0, blue: 34.0/255.0, alpha: 1)
    }

    static let stroke = color(name: ColorName.stroke)

    static let divider = color(name: ColorName.divider)
    static let dividerSecondary = color(name: ColorName.dividerSecondary)
    
    static let buttonActive = UIColor.grayscale50
    static let buttonInactive = color(name: ColorName.buttonInactive)
    static let buttonSelected = color(name: ColorName.buttonSelected)
    static var buttonSecondaryPressed = color(name: ColorName.buttonSecondaryPressed)
    
    /// Color that can be used in case if we couldn't parse color from middleware
    static let defaultColor = grayscale90
    
    private static func color(name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            anytypeAssertionFailure("No color named: \(name)", domain: .colorCreation)
            return defaultColor
        }
        
        return color
    }
}

extension UIColor: AnytypeColorProtocol {
    // MARK: - Stroke colors

    static var strokePrimary: UIColor = AnytypeColor.strokePrimary.asUIColor
    static var strokeSecondary: UIColor = AnytypeColor.strokeSecondary.asUIColor
    static var strokeTertiary: UIColor = AnytypeColor.strokeTertiary.asUIColor
    
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

    // MARK: - Background colors
    static let backgroundPrimary: UIColor = AnytypeColor.backgroundPrimary.asUIColor
    static let backgroundSecondary: UIColor = AnytypeColor.backgroundSecondary.asUIColor
    static var backgroundBlurred: UIColor = AnytypeColor.backgroundBlurred.asUIColor
    static let backgroundSelected: UIColor = AnytypeColor.backgroundSelected.asUIColor
    static var backgroundDashboard: UIColor = AnytypeColor.backgroundDashboard.asUIColor
    
    // MARK: - Grayscale
    
    static let grayscaleWhite: UIColor = AnytypeColor.grayscaleWhite.asUIColor
    static let grayscale90: UIColor = AnytypeColor.grayscale90.asUIColor
    static let grayscale70: UIColor = AnytypeColor.grayscale70.asUIColor
    static let grayscale50: UIColor = AnytypeColor.grayscale50.asUIColor
    static let grayscale30: UIColor = AnytypeColor.grayscale30.asUIColor
    static let grayscale10: UIColor = UIColor.systemGray.withAlphaComponent(0.1)
    
}

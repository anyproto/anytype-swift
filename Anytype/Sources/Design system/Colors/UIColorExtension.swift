import UIKit


extension UIColor {
    static var highlighterColor: UIColor {
        .init(red: 255.0/255.0, green: 181.0/255.0, blue: 34.0/255.0, alpha: 1)
    }
    
    static let textColor = color(name: ColorName.textPrimary)
    static let secondaryTextColor = color(name: ColorName.textSecondary)
    static let tertiaryTextColor = color(name: ColorName.textTertiary)
    
    static var selectedItemColor: UIColor {
        .init(red: 229.0/255.0, green: 239.0/255.0, blue: 249.0/255.0, alpha: 1)
    }
    
    static let grayscale90 = color(name: ColorName.grayscale90)
    static let grayscale50 = color(name: ColorName.grayscale50)
    static let grayscale30 = color(name: ColorName.grayscale30)
    static let grayscale10 = color(name: ColorName.grayscale10)    
    
    static let pureAmber = color(name: ColorName.pureAmber)
    static let pureLemon = color(name: ColorName.pureLemon)
    static let pureRed = color(name: ColorName.pureRed)
    static let purePink = color(name: ColorName.purePink)
    static let purePurple = color(name: ColorName.purePurple)
    static let pureUltramarine = color(name: ColorName.pureUltramarine)
    static let pureBlue = color(name: ColorName.pureBlue)
    static let pureTeal = color(name: ColorName.pureTeal)
    static let pureGreen = color(name: ColorName.pureGreen)
    
    static let darkColdGray = color(name: ColorName.darkColdGray)
    static let lightColdGray = color(name: ColorName.lightColdGray)


    static var darkGreen: UIColor {
        .init(hexString: "#57C600")
    }

    // MARK: - Color for background

    static let grayscaleWhite = color(name: ColorName.grayscaleWhite)

    static var lightLemon: UIColor {
        .init(hexString: "#FEF9CC")
    }

    static var lightAmber: UIColor {
        .init(hexString: "#FEF3C5")
    }

    static var lightRed: UIColor {
        .init(hexString: "#FFEBE5")
    }

    static var lightPink: UIColor {
        .init(hexString: "#FEE3F5")
    }

    static var lightPurple: UIColor {
        .init(hexString: "#F4E3FA")
    }

    static var lightUltramarine: UIColor {
        .init(hexString: "#E4E7FC")
    }

    static let lightBlue = color(name: ColorName.lightBlue)

    static var lightTeal: UIColor {
        .init(hexString: "#D6F5F3")
    }

    static var lightGreen: UIColor {
        .init(hexString: "#E3F7D0")
    }

    static var selected: UIColor {
        .init(hexString: "#867D42", alpha: 0.1)
    }
    
    static let buttonActive = color(name: ColorName.buttonActive)
    static let buttonInactive = color(name: ColorName.buttonInactive)
    static let buttonSelected = color(name: ColorName.buttonSelected)
    
    /// Color that can be used in case if we couldn't parse color from middleware
    static let defaultColor = grayscale90
    
    private static func color(name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            assertionFailure("No color named: \(name)")
            return defaultColor
        }
        
        return color
    }
}

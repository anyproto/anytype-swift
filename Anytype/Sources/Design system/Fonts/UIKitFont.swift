import UIKit
import Services


extension UIFont {

    var bold: UIFont {
        guard !fontDescriptor.symbolicTraits.contains(.traitBold) else { return self }

        switch self {
        case .bodyRegular, .bodyRegular.italic:
            return applyWeight(.semibold)
        default:
            return applyWeight(.bold)
        }
    }

    var regular: UIFont {
        return applyWeight(.regular)
    }

    var italic: UIFont {
        guard !fontDescriptor.symbolicTraits.contains(.traitItalic) else { return self }

        switch self {
        case .bodyRegular.bold:
            return setItalic(enabled: true, .semibold)
        case self.bold:
            return setItalic(enabled: true, .bold)
        default:
            return setItalic(enabled: true, .regular)
        }
    }

    var nonItalic: UIFont {
        guard fontDescriptor.symbolicTraits.contains(.traitItalic) else { return self }

        switch self {
        case .bodyRegular.bold.italic:
            return setItalic(enabled: false, .semibold)
        case self.bold.italic:
            return setItalic(enabled: false, .bold)
        default:
            return setItalic(enabled: false, .regular)
        }
    }

    private func applyWeight(_ weight: UIFont.Weight) -> UIFont {
        let oldTraits = fontDescriptor.symbolicTraits
        var traits: [UIFontDescriptor.TraitKey : Any] = [:]

        if oldTraits.contains(.traitItalic) {
            traits[UIFontDescriptor.TraitKey.symbolic] = UIFontDescriptor.SymbolicTraits.traitItalic.rawValue

        }
        traits[UIFontDescriptor.TraitKey.weight] = weight

        let newDescriptor = UIFontDescriptor(fontAttributes: [
            .traits: traits,
            .family: familyName
        ])

        return UIFont(descriptor: newDescriptor, size: pointSize)
    }

    private func setItalic(enabled: Bool, _ weight: UIFont.Weight) -> UIFont {
        var traits: [UIFontDescriptor.TraitKey : Any] = [:]

        // we need add weight along with traitItalic to create proper font
        traits[UIFontDescriptor.TraitKey.weight] = weight

        if enabled {
            traits[UIFontDescriptor.TraitKey.symbolic] = UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
        }

        let newDescriptor = UIFontDescriptor(fontAttributes: [
            .traits: traits,
            .family: familyName
        ])

        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}


extension UIFont {
    static let title = UIKitFontBuilder.uiKitFont(font: .title)
    static let heading = UIKitFontBuilder.uiKitFont(font: .heading)
    static let subheading = UIKitFontBuilder.uiKitFont(font: .subheading)
    
    static let bodyRegular = UIKitFontBuilder.uiKitFont(font: .bodyRegular)
    static let calloutRegular = UIKitFontBuilder.uiKitFont(font: .calloutRegular)

    static let relation2Regular = UIKitFontBuilder.uiKitFont(font: .relation2Regular)
    static let relation3Regular = UIKitFontBuilder.uiKitFont(font: .relation3Regular)
    static let uxBodyRegular = UIKitFontBuilder.uiKitFont(font: .uxBodyRegular)
    static let caption1Regular = UIKitFontBuilder.uiKitFont(font: .caption1Regular)
    static let caption1Medium = UIKitFontBuilder.uiKitFont(font: .caption1Medium)
    static let uxTitle1Semibold = UIKitFontBuilder.uiKitFont(font: .uxTitle1Semibold)
    static let uxTitle2Regular = UIKitFontBuilder.uiKitFont(font: .uxTitle2Regular)
    static let uxTitle2Medium = UIKitFontBuilder.uiKitFont(font: .uxTitle2Medium) 
    static let uxCalloutRegular = UIKitFontBuilder.uiKitFont(font: .uxCalloutRegular)
    static let uxCalloutMedium = UIKitFontBuilder.uiKitFont(font: .uxCalloutMedium)
    static let previewTitle1Medium = UIKitFontBuilder.uiKitFont(font: .previewTitle1Medium)
    static let previewTitle2Regular = UIKitFontBuilder.uiKitFont(font: .previewTitle2Regular)
    static let previewTitle2Medium = UIKitFontBuilder.uiKitFont(font: .previewTitle2Medium)

    static let code = UIKitFontBuilder.uiKitFont(font: .codeBlock)

    var isCode: Bool {
        return fontName.hasPrefix(AnytypeFontConfig.Name.plex.rawValue)
    }

    static func code(of size: CGFloat) -> UIFont {
        UIKitFontBuilder.uiKitFont(name: .plex, size: size, weight: .regular)
    }
}

extension AnytypeFont {
    var uiKitFont: UIFont {
        UIKitFontBuilder.uiKitFont(font: self)
    }
}


struct UIKitFontBuilder {

    static func uiKitFont(font: AnytypeFont) -> UIFont {
        return uiKitFont(name: font.config.fontName, size: font.config.size, weight: font.config.weight)
    }

    static func uiKitFont(name: AnytypeFontConfig.Name, size: CGFloat, weight: AnytypeFontConfig.Weight) -> UIFont {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        var descriptor = UIFontDescriptor(fontAttributes: [
            attributeKey(name: name): name.rawValue,
            UIFontDescriptor.AttributeName.size: scaledSize,
        ])

        descriptor = descriptor.addingAttributes(
            [
                .traits: [UIFontDescriptor.TraitKey.weight: uiKitWeight(weight)]
            ]
        )

        return UIFont(descriptor: descriptor, size: scaledSize)
    }

    private static func attributeKey(name: AnytypeFontConfig.Name) -> UIFontDescriptor.AttributeName {
        switch name {
        case .plex:
            return UIFontDescriptor.AttributeName.name
        case .inter:
            return UIFontDescriptor.AttributeName.family
        case .riccione:
            return UIFontDescriptor.AttributeName.family
        }
    }

    static func uiKitWeight(_ weight: AnytypeFontConfig.Weight) -> UIFont.Weight {
        switch weight {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }
}

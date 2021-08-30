import UIKit
import BlocksModels


extension UIFont {
    static let title = UIKitFontBuilder.uiKitFont(font: .title)
    static let heading = UIKitFontBuilder.uiKitFont(font: .heading)
    static let subheading = UIKitFontBuilder.uiKitFont(font: .subheading)
    
    static let bodyRegular = UIKitFontBuilder.uiKitFont(font: .bodyRegular)
    static let bodyBold = UIKitFontBuilder.uiKitFont(font: .bodyBold)
    static let calloutRegular = UIKitFontBuilder.uiKitFont(font: .calloutRegular)

    static let relation2Regular = UIKitFontBuilder.uiKitFont(font: .relation2Regular)
    static let relation3Regular = UIKitFontBuilder.uiKitFont(font: .relation3Regular)
    static let uxBodyRegular = UIKitFontBuilder.uiKitFont(font: .uxBodyRegular)
    static let caption1Regular = UIKitFontBuilder.uiKitFont(font: .caption1Regular)
    static let caption1Medium = UIKitFontBuilder.uiKitFont(font: .caption1Medium)
    static let uxTitle2Regular = UIKitFontBuilder.uiKitFont(font: .uxTitle2Regular)
    static let uxCalloutRegular = UIKitFontBuilder.uiKitFont(font: .uxCalloutRegular)
    static let uxCalloutMedium = UIKitFontBuilder.uiKitFont(font: .uxCalloutMedium)
    static let previewTitle2Regular = UIKitFontBuilder.uiKitFont(font: .previewTitle2Regular)

    static let code = UIKitFontBuilder.uiKitFont(font: .codeBlock)

    var isCode: Bool {
        return fontName.hasPrefix(AnytypeFont.FontName.plex.rawValue)
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
        return uiKitFont(name: font.fontName, size: font.size, weight: uiKitWeight(font))
    }

    static func uiKitFont(name: AnytypeFont.FontName, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        var descriptor = UIFontDescriptor(fontAttributes: [
            attributeKey(name: name): name.rawValue,
            UIFontDescriptor.AttributeName.size: scaledSize,
        ])

        descriptor = descriptor.addingAttributes(
            [
                .traits: [ UIFontDescriptor.TraitKey.weight: weight ]
            ]
        )

        return UIFont(descriptor: descriptor, size: scaledSize)
    }

    private static func attributeKey(name: AnytypeFont.FontName) -> UIFontDescriptor.AttributeName {
        switch name {
        case .plex:
            return UIFontDescriptor.AttributeName.name
        case .inter:
            return UIFontDescriptor.AttributeName.family
        }
    }

    private static func uiKitWeight(_ font: AnytypeFont) -> UIFont.Weight {
        switch font.weight {
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

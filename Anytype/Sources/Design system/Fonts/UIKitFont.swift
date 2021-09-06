import UIKit
import BlocksModels


extension UIFont {
    static let title = AnytypeFontBuilder.uiKitFont(textStyle: .title)
    static let heading = AnytypeFontBuilder.uiKitFont(textStyle: .heading)
    static let subheading = AnytypeFontBuilder.uiKitFont(textStyle: .subheading)
    
    static let bodyRegular = AnytypeFontBuilder.uiKitFont(textStyle: .bodyRegular)
    static let bodyBold = AnytypeFontBuilder.uiKitFont(textStyle: .bodyBold)
    static let calloutRegular = AnytypeFontBuilder.uiKitFont(textStyle: .calloutRegular)

    static let relation2Regular = AnytypeFontBuilder.uiKitFont(textStyle: .relation2Regular)
    static let relation3Regular = AnytypeFontBuilder.uiKitFont(textStyle: .relation3Regular)
    static let uxBodyRegular = AnytypeFontBuilder.uiKitFont(textStyle: .uxBodyRegular)
    static let caption1Regular = AnytypeFontBuilder.uiKitFont(textStyle: .caption1Regular)
    static let caption1Medium = AnytypeFontBuilder.uiKitFont(textStyle: .caption1Medium)
    static let uxTitle2Regular = AnytypeFontBuilder.uiKitFont(textStyle: .uxTitle2Regular)
    static let uxCalloutRegular = AnytypeFontBuilder.uiKitFont(textStyle: .uxCalloutRegular)
    static let uxCalloutMedium = AnytypeFontBuilder.uiKitFont(textStyle: .uxCalloutMedium)
    static let previewTitle2Regular = AnytypeFontBuilder.uiKitFont(textStyle: .previewTitle2Regular)

    static let code = AnytypeFontBuilder.uiKitFont(textStyle: .codeBlock)

    var isCode: Bool {
        return fontName.hasPrefix(FontName.plex.rawValue)
    }

    static func code(of size: CGFloat) -> UIFont {
        AnytypeFontBuilder.uiKitFont(name: .plex, size: size, weight: .regular)
    }
}

extension AnytypeFontBuilder {

    static func uiKitFont(textStyle: TextStyle) -> UIFont {
        return uiKitFont(name: fontName(textStyle), size: size(textStyle), weight: uiKitWeight(textStyle))
    }

    static func uiKitFont(name: FontName, size: CGFloat, weight: UIFont.Weight) -> UIFont {
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

    private static func attributeKey(name: FontName) -> UIFontDescriptor.AttributeName {
        switch name {
        case .plex:
            return UIFontDescriptor.AttributeName.name
        case .inter:
            return UIFontDescriptor.AttributeName.family
        }
    }

    private static func uiKitWeight(_ textStyle: TextStyle) -> UIFont.Weight {
        switch weight(textStyle) {
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

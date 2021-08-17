import UIKit
import BlocksModels


extension UIFont {
    static let title = AnytypeFontBuilder.uiKitFont(textStyle: .title)
    static let heading = AnytypeFontBuilder.uiKitFont(textStyle: .heading)
    static let subheading = AnytypeFontBuilder.uiKitFont(textStyle: .subheading)

    static let headlineSemibold = AnytypeFontBuilder.uiKitFont(textStyle: .headlineSemibold)
    static let headline = AnytypeFontBuilder.uiKitFont(textStyle: .headline)

    static let body = AnytypeFontBuilder.uiKitFont(textStyle: .body)
    static let bodyMedium = AnytypeFontBuilder.uiKitFont(textStyle: .bodyMedium)

    static let caption = AnytypeFontBuilder.uiKitFont(textStyle: .caption)
    static let captionMedium = AnytypeFontBuilder.uiKitFont(textStyle: .captionMedium)

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

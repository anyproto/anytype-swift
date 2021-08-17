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

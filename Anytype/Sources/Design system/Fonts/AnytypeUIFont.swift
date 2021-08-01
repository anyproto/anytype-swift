import UIKit
import BlocksModels

extension UIFont {
    static let title = font(name: .graphik, size: 28, weight: .regular)
    static let heading = font(name: .graphik, size: 22, weight: .regular)
    static let subheading = font(name: .graphik, size: 17, weight: .regular)
    
    static let headlineSemibold = font(name: .inter, size: 17, weight: .semibold)
    static let headline = font(name: .inter, size: 17, weight: .regular)
    
    static let body = font(name: .inter, size: 15, weight: .regular)
    static let bodyMedium = font(name: .inter, size: 15, weight: .medium)
    
    static let caption = font(name: .inter, size: 13, weight: .regular)
    static let captionMedium = font(name: .inter, size: 13, weight: .medium)
    
    static let code = font(name: .plex, size: 15, weight: .regular)
    
    var isCode: Bool {
        let attribute = UIFont.attributeKey(name: .plex)
        guard let name = fontDescriptor.fontAttributes[attribute] as? String else { return false }
        return name.hasPrefix(FontName.plex.rawValue) 
    }
    
    static func code(of size: CGFloat) -> UIFont {
        font(name: .plex, size: size, weight: .regular)
    }
    
    private class func font(name: FontName, size: CGFloat, weight: Weight) -> UIFont {
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
        case .graphik, .plex:
            return UIFontDescriptor.AttributeName.name
        case .inter:
            return UIFontDescriptor.AttributeName.family
        }
    }
}

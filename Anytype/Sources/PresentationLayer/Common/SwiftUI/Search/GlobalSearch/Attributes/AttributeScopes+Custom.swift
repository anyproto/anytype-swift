import Foundation
import SwiftUI

extension AttributeScopes {
    struct CustomAttributes: AttributeScope {
        let backgroundHighlight: BackgroundHighlightColorAttributes
    }
    
    var customAttributes: CustomAttributes.Type { CustomAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.CustomAttributes, T>) -> T {
        self[T.self]
    }
}

enum BackgroundHighlightColorAttributes: CodableAttributedStringKey, MarkdownDecodableAttributedStringKey {
    enum Value: String, Codable {
        case sky
    }
    
    static var name = "backgroundHighlight"
}

extension AttributedString {
    var annotateCustomAttributes: AttributedString {
        var attrString = self

        for run in attrString.runs {
            if let background = run.backgroundHighlight, background == .sky {
                attrString[run.range].backgroundColor = Color.VeryLight.sky
            }
        }
        
        return attrString
    }
}

enum BackgroundHighlightAttributeSkyTag {
    static let start = "^["
    static let end = "](\(BackgroundHighlightColorAttributes.name): '\(BackgroundHighlightColorAttributes.Value.sky)')"
}

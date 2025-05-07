import SwiftUI
import AnytypeCore

public struct AnytypeFontBuilder {
    
    private static let fontCache = SynchronizedDictionary<FontCacheKey, Font>()
    
    private struct FontCacheKey: Equatable, Hashable {
        let font: FontConvertible
        let size: CGFloat
    }
    
    public static func font(font: FontConvertible, size: CGFloat) -> Font {
        let fontCacheKey = FontCacheKey(font: font, size: size)
        
        if let cacheFont = fontCache[fontCacheKey] {
            return cacheFont
        }
        
        let font = font.swiftUIFont(size: size)
        
        fontCache[fontCacheKey] = font
        
        return font
    }

    public static func font(anytypeFont: AnytypeFont) -> Font {
        return font(font: anytypeFont.config.font, size: anytypeFont.config.size)
    }
}

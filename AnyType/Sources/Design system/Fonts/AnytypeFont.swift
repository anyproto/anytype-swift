import SwiftUI


// https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile?node-id=0%3A12
extension AnytypeFontBuilder {
    enum TextStyle: CaseIterable {
        case title
        case heading
        case subheading
        
        case headlineSemibold
        case headlineMedium
        case headline
        
        case bodyBold
        case bodySemibold
        case bodyMedium
        case body
        
        case codeBlock
        
        case captionMedium
        case caption
        
        case footnoteMedium
        case footnote
        
        case caption2Medium
        case caption2
    }

    enum FontName: String {
        case graphik = "GraphikLCG-Semibold"
        case plex = "IBMPlexMono"
        case inter = "Inter"
    }
}

struct AnytypeFontBuilder {
    static func font(textStyle: TextStyle) -> Font {
        return font(name: fontName(textStyle), size: size(textStyle), weight: weight(textStyle))
    }
    
    static func font(name: FontName, size: CGFloat, weight: Font.Weight) -> Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return Font.custom(name.rawValue, size: scaledSize).weight(weight)
    }
    
    private static func fontName(_ textStyle: TextStyle) -> FontName {
        switch textStyle {
        case .title, .heading:
            return .graphik
            
        case .subheading, .headline, .body, .caption, .footnote, .caption2:
            fallthrough
        case .headlineMedium, .bodyMedium, .captionMedium, .footnoteMedium, .caption2Medium:
            fallthrough
        case .headlineSemibold, .bodySemibold:
            fallthrough
        case .bodyBold:
            return .inter
            
        case .codeBlock:
            return .plex
        }
    }
    
    private static func size(_ textStyle: TextStyle) -> CGFloat {
        switch textStyle {
        case .title:
            return 28
        case .heading:
            return 22
        case .subheading, .headline, .headlineSemibold, .headlineMedium:
            return 17
        case .body, .bodyBold, .bodySemibold, .bodyMedium, .codeBlock:
            return 15
        case .caption, .captionMedium:
            return 13
        case .footnote, .footnoteMedium:
            return 12
        case .caption2, .caption2Medium:
            return 11
        }
    }
    
    private static func weight(_ textStyle: TextStyle) -> Font.Weight {
        switch textStyle {
        case .title, .heading:
            fallthrough
        case .headline, .body, .caption, .footnote, .caption2:
            fallthrough
        case .codeBlock:
            return .regular
            
        case .headlineMedium, .bodyMedium, .captionMedium, .footnoteMedium, .caption2Medium:
            return .medium
        case .headlineSemibold, .bodySemibold:
            return .semibold
        case .subheading, .bodyBold:
            return .bold
        }
    }
}


extension Font {
    static let defaultAnytype = AnytypeFontBuilder.font(textStyle: .caption)
}

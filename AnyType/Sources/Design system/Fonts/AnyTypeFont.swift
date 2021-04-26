import SwiftUI


// https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile?node-id=0%3A12
extension AnyTypeFont {
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
}


struct AnyTypeFont: ViewModifier {
    
    @Environment(\.sizeCategory) var sizeCategory
    
    
    let textStyle: TextStyle

    func body(content: Content) -> some View {
        return content.font(font())
    }
    
    func font() -> Font {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return applyWeight(Font.custom(fontName, size: scaledSize))
    }
    
    private var fontName: String {
        let graphik = "GraphikLCG-Semibold"
        let plex = "IBMPlexMono-Regular"
        let inter = "Inter"
        
        switch textStyle {
        case .title, .heading:
            return graphik
            
        case .subheading, .headline, .body, .caption, .footnote, .caption2:
            fallthrough
        case .headlineMedium, .bodyMedium, .captionMedium, .footnoteMedium, .caption2Medium:
            fallthrough
        case .headlineSemibold, .bodySemibold:
            fallthrough
        case .bodyBold:
            return inter
            
        case .codeBlock:
            return plex
        }
    }
    
    private var size: CGFloat {
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
    
    private func applyWeight(_ font: Font) -> Font {
        switch textStyle {
        case .title, .heading:
            fallthrough
        case .headline, .body, .caption, .footnote, .caption2:
            fallthrough
        case .codeBlock:
            return font
            
        case .headlineMedium, .bodyMedium, .captionMedium, .footnoteMedium, .caption2Medium:
            return font.weight(.medium)
        case .headlineSemibold, .bodySemibold:
            return font.weight(.semibold)
        case .subheading, .bodyBold:
            return font.bold()
        }
    }
}

extension View {
    func anyTypeFont(_ textStyle: AnyTypeFont.TextStyle) -> some View {
        self.modifier(AnyTypeFont(textStyle: textStyle))
    }
}

extension Font {
    static let defaultAnyType = AnyTypeFont(textStyle: .caption).font()
}

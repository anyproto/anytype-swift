import SwiftUI
import UIKit


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

    enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }
}

struct AnytypeFontBuilder {
    
    static func customLineSpacing(textStyle: TextStyle) -> CGFloat? {
        switch textStyle {
        case .codeBlock:
            return 7
        default:
            return nil
        }
    }
    
    static func fontName(_ textStyle: TextStyle) -> FontName {
        switch textStyle {
        case .title, .heading:
            return .graphik

        case .subheading, .headline, .body, .caption, .footnote, .caption2:
            return .inter
        case .headlineMedium, .bodyMedium, .captionMedium, .footnoteMedium, .caption2Medium:
            return .inter
        case .headlineSemibold, .bodySemibold:
            return .inter
        case .bodyBold:
            return .inter

        case .codeBlock:
            return .plex
        }
    }
    
    static func size(_ textStyle: TextStyle) -> CGFloat {
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

    static func weight(_ textStyle: TextStyle) -> Weight {
        switch textStyle {
        case .title, .heading:
            return .regular
        case .headline, .body, .caption, .footnote, .caption2:
            return .regular
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

struct OptionalLineSpacingModifier: ViewModifier {
    var spacing: CGFloat?
    
    func body(content: Content) -> some View {
        spacing.map { spacing in
            content.lineSpacing(spacing).eraseToAnyView()
        } ?? content.eraseToAnyView()
    }
}

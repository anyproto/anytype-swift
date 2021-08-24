import SwiftUI
import UIKit


// https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile?node-id=0%3A12
extension AnytypeFontBuilder {
    enum TextStyle: CaseIterable {
        // Content fonts
        case title
        case heading
        case subheading
        
        case previewTitle1Medium
        case previewTitle2Regular
        case previewTitle2Medium

        case bodyBold
        case bodyRegular

        case calloutRegular

        case relation1Regular
        case relation2Regular
        case relation3Regular

        case codeBlock

        // UX fonts
        case uxTitle1Semibold
        case uxTitle2Regular
        case uxBodyRegular

        case uxCalloutRegular
        case uxCalloutMedium


        case caption1Regular
        case caption1Medium
        case caption2Regular
        case caption2Medium
        
        case button1Regular
        case button1Semibold


    }

    enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }
}

struct AnytypeFontBuilder {
    
    static func fontName(_ textStyle: TextStyle) -> FontName {
        switch textStyle {
        case .codeBlock:
            return .plex
        default:
            return .inter
        }
    }
    
    static func size(_ textStyle: TextStyle) -> CGFloat {
        switch textStyle {
        case .title:
            return 28
        case .heading:
            return 22
        case .subheading, .previewTitle1Medium, .bodyBold, .bodyRegular, .uxTitle1Semibold,. uxBodyRegular, .button1Regular, .button1Semibold:
            return 17
        case .codeBlock, .previewTitle2Medium, .previewTitle2Regular, .calloutRegular, .relation1Regular, .uxTitle2Regular, .uxCalloutMedium, .uxCalloutRegular:
            return 15
        case .relation2Regular, .caption1Regular, .caption1Medium:
            return 13
        case .relation3Regular:
            return 12
        case .caption2Regular, .caption2Medium:
            return 11
        }
    }

    static func weight(_ textStyle: TextStyle) -> Weight {
        switch textStyle {
        case .title, .heading, .subheading:
            return .bold
        case .previewTitle2Regular, .bodyRegular, .relation1Regular, .calloutRegular, .relation2Regular, .relation3Regular, .codeBlock, .uxBodyRegular, .uxTitle2Regular, .uxCalloutRegular, .caption1Regular, .caption2Regular, .button1Regular:
            return .regular
        case .previewTitle1Medium, .previewTitle2Medium, .uxCalloutMedium, .caption2Medium, .caption1Medium:
            return .medium
        case .bodyBold, .uxTitle1Semibold, .button1Semibold:
            return .semibold
        }
    }

    static func lineHeight(_ textStyle: TextStyle) -> CGFloat {
        switch textStyle {
        case .title:
            return 32
        case .heading:
            return 26
        case .subheading, .bodyBold, .bodyRegular, .uxTitle1Semibold, .uxBodyRegular, .button1Regular, .button1Semibold:
            return 24
        case .codeBlock, .previewTitle1Medium, .calloutRegular, .relation1Regular, .uxCalloutMedium, .uxCalloutRegular:
            return 22
        case .previewTitle2Regular, .previewTitle2Medium, .uxTitle2Regular:
            return 20
        case .caption1Medium, .relation2Regular, .caption1Regular:
            return 18
        case .relation3Regular:
            return 15
        case .caption2Regular, .caption2Medium:
            return 14
        }
    }

    /// Line spacing.
    ///
    /// In desing tool to specify space between lines used line height font parameter.  iOS API have only line spacing attribute.
    /// So if in desing font line height differ from default value we need calculate line spacing by self.
    ///
    /// To set correct line spacing we need do follow:
    /// - Get default line height of font. We can do it progrmmatically using lineHeight font property.
    /// - Calculate and set line spacing. **Line spacing = Line height in design - Default line height**.
    /// - Set  top/bottom space for text view as  **Top/Bottom Space =  Line spacing / 2**.
    ///
    /// - Parameter textStyle: Text style type.
    /// - Returns: Line spacing for given text style.
    static func lineSpacing(_ textStyle: TextStyle) -> CGFloat {
        return lineHeight(textStyle) - uiKitFont(textStyle: textStyle).lineHeight
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

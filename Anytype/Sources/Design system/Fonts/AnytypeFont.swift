import SwiftUI
import UIKit


// https://www.figma.com/file/vgXV7x2v20vJajc7clYJ7a/Typography-Mobile?node-id=0%3A12
enum AnytypeFont: CaseIterable {
    // Content fonts
    case title
    case heading
    case subheading

    case previewTitle1Medium
    case previewTitle2Regular
    case previewTitle2Medium

    case body

    case callout

    case relation1Regular
    case relation2Regular
    case relation3Regular

    case codeBlock

    // UX fonts
    case uxTitle1Semibold
    case uxTitle2Regular
    case uxTitle2Medium
    case uxBodyRegular

    case uxCalloutRegular
    case uxCalloutMedium


    case caption1Regular
    case caption1Medium
    case caption2Regular
    case caption2Medium

    case button1Regular
    case button1Semibold

    enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }

    enum FontName: String {
        case plex = "IBMPlexMono"
        case inter = "Inter"
    }

    var fontName: FontName {
        switch self {
        case .codeBlock:
            return .plex
        default:
            return .inter
        }
    }

    var size: CGFloat {
        switch self {
        case .title:
            return 28
        case .heading:
            return 22
        case .subheading, .previewTitle1Medium, .body, .uxTitle1Semibold,. uxBodyRegular, .button1Regular, .button1Semibold:
            return 17
        case .codeBlock, .previewTitle2Medium, .previewTitle2Regular, .callout, .relation1Regular, .uxTitle2Regular, .uxCalloutMedium, .uxCalloutRegular, .uxTitle2Medium:
            return 15
        case .relation2Regular, .caption1Regular, .caption1Medium:
            return 13
        case .relation3Regular:
            return 12
        case .caption2Regular, .caption2Medium:
            return 11
        }
    }

    var weight: Weight {
        switch self {
        case .title, .heading, .subheading:
            return .bold
        case .previewTitle2Regular, .body, .relation1Regular, .callout, .relation2Regular, .relation3Regular, .codeBlock, .uxBodyRegular, .uxTitle2Regular, .uxCalloutRegular, .caption1Regular, .caption2Regular, .button1Regular:
            return .regular
        case .previewTitle1Medium, .previewTitle2Medium, .uxCalloutMedium, .caption2Medium, .caption1Medium, .uxTitle2Medium:
            return .medium
        case .uxTitle1Semibold, .button1Semibold:
            return .semibold
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .title:
            return 32
        case .heading:
            return 26
        case .subheading, .body, .uxTitle1Semibold, .uxBodyRegular, .button1Regular, .button1Semibold:
            return 24
        case .codeBlock, .previewTitle1Medium, .callout, .uxCalloutMedium, .uxCalloutRegular:
            return 22
        case .previewTitle2Regular, .previewTitle2Medium, .uxTitle2Regular, .uxTitle2Medium, .relation1Regular:
            return 20
        case .caption1Medium, .relation2Regular, .caption1Regular:
            return 18
        case .relation3Regular:
            return 15
        case .caption2Regular, .caption2Medium:
            return 14
        }
    }

    /// Font kern. If nil then use default.
    var kern: CGFloat {
        switch self {
        case .title:
            return -0.48
        case .heading:
            return -0.36
        case .subheading:
            return -0.28
        case .previewTitle1Medium, .body, .uxTitle1Semibold, .uxBodyRegular, .button1Regular, .button1Semibold:
            return -0.41
        case .previewTitle2Regular, .relation3Regular, .previewTitle2Medium, .callout, .relation1Regular, .codeBlock, .uxTitle2Regular, .uxTitle2Medium, .uxCalloutMedium, .uxCalloutRegular:
            return -0.24
        case .caption1Medium, .relation2Regular, .caption1Regular:
            return -0.08
        case .caption2Regular, .caption2Medium:
            return -0.07
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
    var lineSpacing: CGFloat {
        return lineHeight - UIKitFontBuilder.uiKitFont(font: self).lineHeight
    }
}

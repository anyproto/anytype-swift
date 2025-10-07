import Foundation

public struct AnytypeFontConfig {
    public let font: FontConvertible
    public let size: CGFloat
    public let lineHeight: CGFloat
    public let kern: CGFloat
}

public extension AnytypeFont {
    var config: AnytypeFontConfig {
        switch self {
        case .title:
            return AnytypeFontConfig(
                font: FontFamily.Inter.bold,
                size: 28,
                lineHeight: 32,
                kern: -0.48
            )
        case .heading:
            return AnytypeFontConfig(
                font: FontFamily.Inter.bold,
                size: 22,
                lineHeight: 26,
                kern: -0.36
            )
        case .subheading:
            return AnytypeFontConfig(
                font: FontFamily.Inter.bold,
                size: 17,
                lineHeight: 24,
                kern: -0.28
            )
        case .previewTitle1Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 17,
                lineHeight: 22,
                kern: -0.41
            )
        case .previewTitle1Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 22,
                kern: -0.41
            )
        case .previewTitle2Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .previewTitle2Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .bodyRegular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .bodySemibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .calloutRegular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 22,
                kern: -0.24
            )
        case .relation1Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .relation2Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 13,
                lineHeight: 18,
                kern: -0.08
            )
        case .relation3Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 12,
                lineHeight: 15,
                kern: 0
            )
        case .codeBlock:
            return AnytypeFontConfig(
                font: FontFamily.IBMPlexMono.regular,
                size: 15,
                lineHeight: 22,
                kern: -0.24
            )
        case .chatText:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 20,
                kern: -0.41
            )
        case .chatPreviewMedium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 15,
                lineHeight: 18,
                kern: -0.24
            )
        case .chatPreviewRegular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 18,
                kern: -0.24
            )
        case .contentTitleSemibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 28,
                lineHeight: 32,
                kern: -0.48
            )
        case .uxTitle1Semibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .uxTitle2Semibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxTitle2Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxTitle2Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxBodyRegular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .uxCalloutRegular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 15,
                lineHeight: 22,
                kern: -0.24
            )
        case .uxCalloutMedium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 15,
                lineHeight: 22,
                kern: -0.24
            )
        case .caption1Semibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 13,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption1Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 13,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption1Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 13,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption2Semibold:
            return AnytypeFontConfig(
                font: FontFamily.Inter.bold,
                size: 11,
                lineHeight: 14,
                kern: -0.07
            )
        case .caption2Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 11,
                lineHeight: 14,
                kern: 0.07
            )
        case .caption2Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 11,
                lineHeight: 14,
                kern: -0.07
            )
        case .button1Regular:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .button1Medium:
            return AnytypeFontConfig(
                font: FontFamily.Inter.medium,
                size: 17,
                lineHeight: 24,
                kern: -0.41
            )
        case .authBody:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 14,
                lineHeight: 22,
                kern: -0.24
            )
        case .authCaption:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 12,
                lineHeight: 18,
                kern: -0.08
            )
        case .authInput:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 17,
                lineHeight: 22,
                kern: -0.24
            )
        case .navigationBarTitle:
            return AnytypeFontConfig(
                font: FontFamily.Inter.semiBold,
                size: 15,
                lineHeight: 20,
                kern: -0.24
            )
        case .authEmoji:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 44,
                lineHeight: 56,
                kern: -0.48
            )
        case .riccioneBannerTitle:
            return AnytypeFontConfig(
                font: FontFamily.RiccioneXlight.regular,
                size: 48,
                lineHeight: 44,
                kern: -0.52
            )
        case .interBannerTitle:
            return AnytypeFontConfig(
                font: FontFamily.Inter.light,
                size: 48,
                lineHeight: 48,
                kern: -1.6
            )
        case .riccioneTitle:
            return AnytypeFontConfig(
                font: FontFamily.RiccioneXlight.regular,
                size: 44,
                lineHeight: 44,
                kern: -0.08
            )
        case .interTitle:
            return AnytypeFontConfig(
                font: FontFamily.Inter.regular,
                size: 40,
                lineHeight: 44,
                kern: -2
            )
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
        return config.lineHeight - UIKitFontBuilder.uiKitFont(font: self).lineHeight
    }
    
    var lineHeightMultiple: CGFloat {
        return config.lineHeight / UIKitFontBuilder.uiKitFont(font: self).lineHeight
    }
}

import Foundation

struct AnytypeFontConfig {
    let fontName: Name
    let size: CGFloat
    let weight: Weight
    let lineHeight: CGFloat
    let kern: CGFloat
    
    enum Name: String {
        case plex = "IBMPlexMono"
        case inter = "Inter"
        case riccione = "Riccione-Xlight"
    }
    
    enum Weight {
        case regular
        case medium
        case semibold
        case bold
        case light
    }
}

extension AnytypeFont {
    var config: AnytypeFontConfig {
        switch self {
        case .title:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 28,
                weight: .bold,
                lineHeight: 32,
                kern: -0.48
            )
        case .heading:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 22,
                weight: .bold,
                lineHeight: 26,
                kern: -0.36
            )
        case .subheading:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .bold,
                lineHeight: 24,
                kern: -0.28
            )
        case .previewTitle1Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .medium,
                lineHeight: 22,
                kern: -0.41
            )
        case .previewTitle1Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 22,
                kern: -0.41
            )
        case .previewTitle2Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .regular,
                lineHeight: 20,
                kern: -0.24
            )
        case .previewTitle2Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .medium,
                lineHeight: 20,
                kern: -0.24
            )
        case .bodyRegular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 24,
                kern: -0.41
            )
        case .bodySemibold:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .semibold,
                lineHeight: 24,
                kern: -0.41
            )
        case .calloutRegular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .regular,
                lineHeight: 22,
                kern: -0.24
            )
        case .relation1Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .regular,
                lineHeight: 20,
                kern: -0.24
            )
        case .relation2Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 13,
                weight: .regular,
                lineHeight: 18,
                kern: -0.08
            )
        case .relation3Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 12,
                weight: .regular,
                lineHeight: 15,
                kern: 0
            )
        case .codeBlock:
            return AnytypeFontConfig(
                fontName: .plex,
                size: 15,
                weight: .regular,
                lineHeight: 22,
                kern: -0.24
            )
        case .chatText:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 20,
                kern: -0.41
            )
        case .uxTitle1Semibold:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .semibold,
                lineHeight: 24,
                kern: -0.41
            )
        case .uxTitle2Semibold:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .semibold,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxTitle2Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .regular,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxTitle2Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .medium,
                lineHeight: 20,
                kern: -0.24
            )
        case .uxBodyRegular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 24,
                kern: -0.41
            )
        case .uxCalloutRegular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .regular,
                lineHeight: 22,
                kern: -0.24
            )
        case .uxCalloutMedium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .medium,
                lineHeight: 22,
                kern: -0.24
            )
        case .caption1Semibold:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 13,
                weight: .bold,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption1Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 13,
                weight: .regular,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption1Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 13,
                weight: .medium,
                lineHeight: 18,
                kern: -0.08
            )
        case .caption2Semibold:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 11,
                weight: .bold,
                lineHeight: 14,
                kern: -0.07
            )
        case .caption2Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 11,
                weight: .regular,
                lineHeight: 14,
                kern: 0.07
            )
        case .caption2Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 11,
                weight: .medium,
                lineHeight: 14,
                kern: -0.07
            )
        case .button1Regular:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 24,
                kern: -0.41
            )
        case .button1Medium:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .medium,
                lineHeight: 24,
                kern: -0.41
            )
        case .authBody:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 14,
                weight: .regular,
                lineHeight: 22,
                kern: -0.24
            )
        case .authCaption:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 12,
                weight: .regular,
                lineHeight: 18,
                kern: -0.08
            )
        case .authInput:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 17,
                weight: .regular,
                lineHeight: 22,
                kern: -0.24
            )
        case .navigationBarTitle:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 15,
                weight: .semibold,
                lineHeight: 20,
                kern: -0.24
            )
        case .authEmoji:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 44,
                weight: .regular,
                lineHeight: 56,
                kern: -0.48
            )
        case .riccioneBannerTitle:
            return AnytypeFontConfig(
                fontName: .riccione,
                size: 48,
                weight: .regular,
                lineHeight: 44,
                kern: -0.52
            )
        case .interBannerTitle:
            return AnytypeFontConfig(
                fontName: .inter,
                size: 48,
                weight: .light,
                lineHeight: 48,
                kern: -1.6
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

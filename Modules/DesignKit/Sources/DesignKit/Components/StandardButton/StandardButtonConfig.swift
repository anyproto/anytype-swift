import SwiftUI

public struct StandardButtonConfig {

    public struct Style {
        public var textColor: Color? = nil
        public var borderColor: Color? = nil
        public var backgroundColor: Color? = nil
        public var overlayBackgroundColor: Color? = nil
        
        func mergeWith(config: Style?) -> Style {
            Style(
                textColor: config?.textColor ?? textColor,
                borderColor: config?.borderColor ?? borderColor,
                backgroundColor: config?.backgroundColor ?? backgroundColor,
                overlayBackgroundColor: config?.overlayBackgroundColor ?? overlayBackgroundColor
            )
        }
    }
    
    public var normal: Style
    public var higlighted: Style? = nil
    public var disabled: Style? = nil
    
    public var textFont: AnytypeFont
    public var infoTextFont: AnytypeFont? = nil
    public var height: Double
    public var stretchSize: Bool
    public var radius: Double
    public var loadingIndicatorSize: CGSize
    public var horizontalPadding: Double = 12
}

private extension CGSize {
    enum ButtonLoadingIndicator {
        static let large = CGSize(width: 50, height: 6)
        static let small = CGSize(width: 42, height: 6)
        static let xsmall = CGSize(width: 34, height: 6)
    }
}

public extension StandardButtonStyle {
    
    var config: StandardButtonConfig {
        switch self {
        case .primaryLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.inversion,
                    backgroundColor: .Control.button
                ),
                higlighted: StandardButtonConfig.Style(
                    overlayBackgroundColor: Color(light: .white.opacity(0.15), dark: .black.opacity(0.15))
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary,
                    backgroundColor: .Shape.tertiary
                ),
                textFont: .button1Medium,
                infoTextFont: .caption1Medium,
                height: 48,
                stretchSize: true,
                radius: 12,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .secondaryLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.primary,
                    borderColor: .Shape.primary
                ),
                higlighted: StandardButtonConfig.Style(
                    backgroundColor: .Shape.transperentSecondary
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary,
                    borderColor: .Shape.primary
                ),
                textFont: .button1Regular,
                height: 48,
                stretchSize: true,
                radius: 12,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .warningLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .System.red,
                    borderColor: .Shape.primary
                ),
                higlighted: StandardButtonConfig.Style(
                    textColor: .Light.red
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Light.red,
                    borderColor: .Shape.secondary
                ),
                textFont: .button1Medium,
                height: 48,
                stretchSize: true,
                radius: 12,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .borderlessLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.secondary,
                    borderColor: .clear
                ),
                higlighted: StandardButtonConfig.Style(
                    textColor: .Text.tertiary
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary
                ),
                textFont: .button1Regular,
                height: 48,
                stretchSize: true,
                radius: 0,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .primaryMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .button1Medium,
                height: 44,
                stretchSize: true,
                radius: 10,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .secondaryMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .uxBodyRegular,
                height: 44,
                stretchSize: true,
                radius: 10,
                loadingIndicatorSize: .ButtonLoadingIndicator.large,
                horizontalPadding: 12
            )
        case .warningMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .button1Medium,
                height: 44,
                stretchSize: true,
                radius: 10,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        case .primarySmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .uxCalloutMedium,
                height: 36,
                stretchSize: false,
                radius: 8,
                loadingIndicatorSize: .ButtonLoadingIndicator.small
            )
        case .secondarySmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .uxCalloutRegular,
                height: 36,
                stretchSize: false,
                radius: 8,
                loadingIndicatorSize: .ButtonLoadingIndicator.small
            )
        case .warningSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .uxCalloutMedium,
                height: 36,
                stretchSize: false,
                radius: 8,
                loadingIndicatorSize: .ButtonLoadingIndicator.small
            )
        case .borderlessSmall:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.secondary,
                    borderColor: .clear
                ),
                higlighted: StandardButtonConfig.Style(
                    textColor: .Text.tertiary
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary
                ),
                textFont: .uxBodyRegular,
                height: 48,
                stretchSize: false,
                radius: 0,
                loadingIndicatorSize: .ButtonLoadingIndicator.small,
                horizontalPadding: 0
            )
        case .primaryXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .caption1Medium,
                height: 28,
                stretchSize: false,
                radius: 6,
                loadingIndicatorSize: .ButtonLoadingIndicator.xsmall,
                horizontalPadding: 10
            )
        case .primaryXSmallStretched:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .caption1Medium,
                height: 28,
                stretchSize: true,
                radius: 6,
                loadingIndicatorSize: .ButtonLoadingIndicator.xsmall,
                horizontalPadding: 10
            )
        case .secondaryXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .caption1Regular,
                height: 28,
                stretchSize: false,
                radius: 6,
                loadingIndicatorSize: .ButtonLoadingIndicator.xsmall
            )
        case .warningXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .caption1Medium,
                height: 28,
                stretchSize: false,
                radius: 6,
                loadingIndicatorSize: .ButtonLoadingIndicator.xsmall
            )
        case .transparentXSmall:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.inversion,
                    backgroundColor: .Control.transparentActive
                ),
                higlighted: StandardButtonConfig.Style(
                    overlayBackgroundColor: Color(light: .white.opacity(0.15), dark: .black.opacity(0.15))
                ),
                disabled: StandardButtonConfig.Style(
                    backgroundColor: .Control.transparentInactive
                ),
                textFont: .caption1Medium,
                height: 28,
                stretchSize: false,
                radius: 6,
                loadingIndicatorSize: .ButtonLoadingIndicator.xsmall
            )
        case .upgradeBadge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.inversion,
                    backgroundColor: .Control.button
                ),
                higlighted: StandardButtonConfig.Style(
                    overlayBackgroundColor: Color(light: .white.opacity(0.15), dark: .black.opacity(0.15))
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary,
                    backgroundColor: .Shape.tertiary
                ),
                textFont: .calloutRegular,
                height: 32,
                stretchSize: true,
                radius: 18,
                loadingIndicatorSize: .ButtonLoadingIndicator.large
            )
        }
    }
}

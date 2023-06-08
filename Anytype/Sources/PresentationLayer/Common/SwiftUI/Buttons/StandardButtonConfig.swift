import SwiftUI

struct StandardButtonConfig {

    struct Style {
        var textColor: Color? = nil
        var borderColor: Color? = nil
        var backgroundColor: Color? = nil
        var overlayBackgroundColor: Color? = nil
        
        func mergeWith(config: Style?) -> Style {
            Style(
                textColor: config?.textColor ?? textColor,
                borderColor: config?.borderColor ?? borderColor,
                backgroundColor: config?.backgroundColor ?? backgroundColor,
                overlayBackgroundColor: config?.overlayBackgroundColor ?? overlayBackgroundColor
            )
        }
    }
    
    var normal: Style
    var higlighted: Style? = nil
    var disabled: Style? = nil
    
    var textFont: AnytypeFont
    var infoTextFont: AnytypeFont? = nil
    var height: Double
    var stretchSize: Bool
    var radius: Double
}


extension StandardButtonStyle {
    
    var config: StandardButtonConfig {
        switch self {
        case .primaryLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.labelInversion,
                    backgroundColor: .Button.button
                ),
                higlighted: StandardButtonConfig.Style(
                    overlayBackgroundColor: Color(light: .white.opacity(0.15), dark: .black.opacity(0.15))
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary,
                    backgroundColor: .Stroke.tertiary
                ),
                textFont: .button1Medium,
                infoTextFont: .caption1Medium,
                height: 48,
                stretchSize: true,
                radius: 12
            )
        case .secondaryLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .Text.primary,
                    borderColor: .Stroke.primary
                ),
                higlighted: StandardButtonConfig.Style(
                    backgroundColor: .Stroke.transperent
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Text.tertiary,
                    borderColor: .Stroke.primary
                ),
                textFont: .button1Regular,
                height: 48,
                stretchSize: true,
                radius: 12
            )
        case .warningLarge:
            return StandardButtonConfig(
                normal: StandardButtonConfig.Style(
                    textColor: .System.red,
                    borderColor: .Stroke.primary
                ),
                higlighted: StandardButtonConfig.Style(
                    textColor: .Light.red
                ),
                disabled: StandardButtonConfig.Style(
                    textColor: .Light.red,
                    borderColor: .Stroke.secondary
                ),
                textFont: .button1Medium,
                height: 48,
                stretchSize: true,
                radius: 12
            )
        case .primaryMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .button1Medium,
                height: 44,
                stretchSize: true,
                radius: 10
            )
        case .secondaryMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .uxBodyRegular,
                height: 44,
                stretchSize: true,
                radius: 10
            )
        case .warningMedium:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .button1Medium,
                height: 44,
                stretchSize: true,
                radius: 10
            )
        case .primarySmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .uxCalloutMedium,
                height: 36,
                stretchSize: false,
                radius: 8
            )
        case .secondarySmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .uxCalloutRegular,
                height: 36,
                stretchSize: false,
                radius: 8
            )
        case .warningSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .uxCalloutMedium,
                height: 36,
                stretchSize: false,
                radius: 8
            )
        case .primaryXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.primaryLarge.config.normal,
                higlighted: StandardButtonStyle.primaryLarge.config.higlighted,
                disabled: StandardButtonStyle.primaryLarge.config.disabled,
                textFont: .caption1Medium,
                height: 28,
                stretchSize: false,
                radius: 6
            )
        case .secondaryXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.secondaryLarge.config.normal,
                higlighted: StandardButtonStyle.secondaryLarge.config.higlighted,
                disabled: StandardButtonStyle.secondaryLarge.config.disabled,
                textFont: .caption1Regular,
                height: 28,
                stretchSize: false,
                radius: 6
            )
        case .warningXSmall:
            return StandardButtonConfig(
                normal: StandardButtonStyle.warningLarge.config.normal,
                higlighted: StandardButtonStyle.warningLarge.config.higlighted,
                disabled: StandardButtonStyle.warningLarge.config.disabled,
                textFont: .caption1Medium,
                height: 28,
                stretchSize: false,
                radius: 6
            )
        }
    }
}

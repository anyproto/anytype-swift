import SwiftUI
import AnytypeCore
import Assets

public typealias StandardButtonAction = () -> Void

public struct StandardButton: View {
    public enum Content {
        case text(String)
        case image(ImageAsset)
        case textWithBadge(text: String, badge: String)
    }
    
    let content: Content
    let info: String?
    let inProgress: Bool
    let style: StandardButtonStyle
    let action: StandardButtonAction
    let corners: UIRectCorner
    let holdPressState: Bool // Use only for demo
    
    @State private var isPressed: Bool = false
    @Environment(\.isEnabled) private var isEnable
    @Environment(\.redactionReasons) private var redactionReasons
    
    public init(
        _ content: Content,
        info: String? = nil,
        inProgress: Bool = false,
        style: StandardButtonStyle,
        holdPressState: Bool = false,
        corners: UIRectCorner = .allCorners,
        action: @escaping StandardButtonAction
    ) {
        self.content = content
        self.info = info
        self.inProgress = inProgress
        self.style = style
        self.holdPressState = holdPressState
        self.corners = corners
        self.action = action
    }
    
    public var body: some View {
        Button {
            if !inProgress {
                action()
            }
        } label: {
            contentView
        }
        .buttonStyle(StandardPlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity) {
            // Nothing
        } onPressingChanged: { pressing in
            if !inProgress {
                isPressed = pressing
            }
        }
        .if(redactionReasons == .placeholder) {
            $0.disabled(true)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        let colorConfigStyle = buildColorConfigStyle()

        Group {
            switch content {
            case let .text(text):
                AnytypeText(
                    text,
                    style: style.config.textFont
                )
                .foregroundColor(colorConfigStyle.textColor ?? .Text.primary)
                .padding(.horizontal, style.config.horizontalPadding)
                .multilineTextAlignment(.center)
            case let .image(asset):
                Image(asset: asset)
                    .foregroundColor(colorConfigStyle.textColor ?? .Text.primary)
                    .padding(.horizontal, 5)
            case let .textWithBadge(text, badge):
                HStack(spacing: 8) {
                    AnytypeText(text, style: style.config.textFont)
                        .foregroundColor(colorConfigStyle.textColor ?? .Text.primary)
                    AnytypeText(badge, style: style.config.textFont)
                        .foregroundColor(Color.Control.secondary)
                }
                .padding(.horizontal, style.config.horizontalPadding)
            }
        }
        .setZeroOpacity(inProgress)
        .if(style.config.stretchSize) {
            $0.frame(minWidth: 0, maxWidth: .infinity)
        }
        .frame(height: style.config.height)
        .background(background(style: colorConfigStyle))
        .cornerRadius(style.config.radius, corners: corners)
        .ifLet(colorConfigStyle.borderColor) { view, borderColor in
            view.overlay(
                RoundedRectangle(cornerRadius: style.config.radius, style: .continuous).strokeBorder(borderColor, lineWidth: 1)
            )
        }
        .fixTappableArea()
        .overlay(progressView(config: colorConfigStyle), alignment: .center)
        .overlay(infoView, alignment: .trailing)
        .transaction { $0.animation = nil } // Disable animations for background
        .scaleEffect(isPressed ? 0.94 : 1)
        .animation(.easeOut(duration: 0.15), value: isPressed)
    }
    
    private func buildColorConfigStyle() -> StandardButtonConfig.Style {
        if holdPressState || isPressed {
            return style.config.normal.mergeWith(config: style.config.higlighted)
        } else if !isEnable {
            return style.config.normal.mergeWith(config: style.config.disabled)
        } else {
            return style.config.normal
        }
    }
    
    private func buildInfoColorConfigStyle() -> StandardButtonConfig.Style {
        if holdPressState || isPressed {
            return style.config.normal
        } else {
            return style.config.normal.mergeWith(config: style.config.higlighted)
        }
    }
    
    @ViewBuilder
    private func background(style: StandardButtonConfig.Style) -> some View {
        Color.clear
            .overlay(style.backgroundColor)
            .overlay(style.overlayBackgroundColor)
    }
    
    @ViewBuilder
    private func progressView(config: StandardButtonConfig.Style) -> some View {
        if inProgress {
            DotsView()
                .foregroundColor(config.textColor)
                .frame(width: style.config.loadingIndicatorSize.width, height: style.config.loadingIndicatorSize.height)
        }
    }
    
    @ViewBuilder
    private var infoView: some View {
        if let info, let infoTextFont = style.config.infoTextFont {
            let infoColorConfigStyle = buildInfoColorConfigStyle()
            AnytypeText(info, style: infoTextFont)
                .foregroundColor(infoColorConfigStyle.textColor ?? .Text.primary)
                .frame(width: 24, height: 24)
                .background(background(style: infoColorConfigStyle))
                .clipShape(Circle())
                .padding(.trailing, 12)
        }
    }
}

public extension StandardButton {
    init(model: StandardButtonModel) {
        self.init(
            model.text,
            inProgress: model.inProgress,
            style: model.style,
            action: model.action
        )
    }
    
    init(
        _ text: String,
        info: String? = nil,
        inProgress: Bool = false,
        style: StandardButtonStyle,
        holdPressState: Bool = false,
        corners: UIRectCorner = .allCorners,
        action: @escaping StandardButtonAction
    ) {
        self.content = .text(text)
        self.info = info
        self.inProgress = inProgress
        self.style = style
        self.holdPressState = holdPressState
        self.corners = corners
        self.action = action
    }
}

import SwiftUI

public struct GradientHeaderAlertView<HeaderContent: View>: View {
    
    public let title: String
    public let message: String
    public let style: GradientHeaderAlertStyle
    public let headerContentView: HeaderContent
    public let buttons: [GradientHeaderAlertButton]
    
    public init(
        title: String,
        message: String,
        style: GradientHeaderAlertStyle,
        @ViewBuilder headerContentView: () -> HeaderContent,
        buttons: [GradientHeaderAlertButton]
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.headerContentView = headerContentView()
        self.buttons = buttons
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            header
            
            Spacer.fixedHeight(20)
            
            text
            
            Spacer.fixedHeight(20)

            buttonsView
            
            Spacer.fixedHeight(16)
        }
        .background(Color.Background.secondary)
    }
    
    private var header: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        style.startColor,
                        style.endColor
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            headerContentView
        }
        .frame(height: 232)
    }
    
    private var text: some View {
        VStack(spacing: 8) {
            AnytypeText(title, style: .heading)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
            
            AnytypeText(message, style: .bodyRegular)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    private var buttonsView: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.id) { button in
                StandardButton(
                    button.title,
                    inProgress: button.inProgress,
                    style: button.style,
                    action: button.action
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

public struct GradientHeaderAlertButton: Identifiable {
    public let id = UUID().uuidString
    public let title: String
    public let style: StandardButtonStyle
    public let inProgress: Bool
    public let action: () -> Void
    
    public init(title: String, style: StandardButtonStyle, inProgress: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.inProgress = inProgress
        self.action = action
    }
}

public enum GradientHeaderAlertStyle {
    case violet
    case red
    
    var startColor: Color {
        switch self {
        case .violet:
            return Color.Gradients.HeaderAlert.violetStart
        case .red:
            return Color.Gradients.HeaderAlert.redStart
        }
    }
    
    var endColor: Color {
        switch self {
        case .violet:
            return Color.Gradients.HeaderAlert.violetEnd
        case .red:
            return Color.Gradients.HeaderAlert.redEnd
        }
    }
}

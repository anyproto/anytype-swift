import SwiftUI

enum StandardButtonStyle {
    case primary
    case secondary
    
    var backgroundColor: Color {
        switch self {
        case .secondary:
            return .buttonSecondary
        case .primary:
            return .buttonPrimary
        }
    }
    
    var textColor: Color {
        switch self {
        case .secondary:
            return .buttonSecondaryText
        case .primary:
            return .buttonPrimartText
        }
    }
    
    var borderColor: Color? {
        switch self {
        case .secondary:
            return .buttonSecondaryBorder
        case .primary:
            return nil
        }
    }
}

struct StandardButtonView: View {
    var disabled: Bool = false
    let text: String
    let style: StandardButtonStyle
    
    var body: some View {
        AnytypeText(text, style: style == .primary ? .button1Semibold : .button1Regular)
            .padding(.all)
            .foregroundColor(disabled ? .textSecondary : style.textColor)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(style.backgroundColor)
            .cornerRadius(8.0)
            .eraseToAnyView()
            .ifLet(style.borderColor) { button, borderColor in
                button.overlay(
                    RoundedRectangle(cornerRadius: 8.0).stroke(borderColor, lineWidth: 1)
                )
            }
    }
}

struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StandardButton(disabled: false ,text: "Button text", style: .secondary, action: {})
            StandardButton(disabled: true ,text: "Button text", style: .secondary, action: {})
            StandardButton(disabled: false ,text: "Button text", style: .primary, action: {})
            StandardButton(disabled: true ,text: "Button text", style: .primary, action: {})
        }.padding()
    }
}

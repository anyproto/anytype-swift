import SwiftUI

enum StandardButtonStyle {
    case primary
    case secondary
    
    func backgroundColor(disabled: Bool) -> Color {
        switch self {
        case .secondary:
            return .buttonSecondary
        case .primary:
            if disabled {
                return .stroke
            } else {
                return .buttonPrimary
            }
        }
    }
    
    func textColor(disabled: Bool) -> Color {
        switch self {
        case .secondary:
            if disabled {
                return .textSecondary
            } else {
                return .buttonSecondaryText
            }
        case .primary:
            if disabled {
                return .white
            } else {
                return .buttonPrimartText
            }
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
            .foregroundColor(style.textColor(disabled: disabled))
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 48)
            .background(style.backgroundColor(disabled: disabled))
            .cornerRadius(10.0)
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
            StandardButton(disabled: false ,text: "Secondary enabled", style: .secondary, action: {})
            StandardButton(disabled: true ,text: "Secondary disabled", style: .secondary, action: {})
            StandardButton(disabled: false ,text: "Primary enabled", style: .primary, action: {})
            StandardButton(disabled: true ,text: "Primary disabled", style: .primary, action: {})
        }.padding()
    }
}

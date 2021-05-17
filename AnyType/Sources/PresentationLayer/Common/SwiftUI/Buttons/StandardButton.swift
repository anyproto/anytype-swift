import SwiftUI


typealias StandardButtonAction = () -> Void

enum StandardButtonStyle {
    case primary
    case secondary
    
    func backgroundColor() -> Color {
        switch self {
        case .secondary:
            return .buttonSecondary
        case .primary:
            return .buttonPrimary
        }
    }
    
    func textColor() -> Color {
        switch self {
        case .secondary:
            return .buttonSecondaryText
        case .primary:
            return .buttonPrimartText
        }
    }
    
    func borderColor() -> Color? {
        switch self {
        case .secondary:
            return .buttonSecondaryBorder
        case .primary:
            return nil
        }
    }
}

struct StandardButton: View {
    var disabled: Bool = false
    var text: String
    var style: StandardButtonStyle
    var action: StandardButtonAction
    
    var body: some View {
        var button = Button(action: {
            self.action()
        }) {
            AnytypeText(text, style: .headline)
                .padding(.all)
                .foregroundColor(disabled ? .textSecondary : style.textColor())
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(style.backgroundColor())
                .cornerRadius(8.0)
        }
        .disabled(disabled)
        .eraseToAnyView()
        
        if let borderColor = style.borderColor(){
            button = button.overlay(
                RoundedRectangle(cornerRadius: 8.0).stroke(borderColor, lineWidth: 1)
            ).eraseToAnyView()
        }
        
        return button
    }
}

struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardButton(disabled: false ,text: "Standard button", style: .secondary, action: {})
    }
}

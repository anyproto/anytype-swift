import SwiftUI

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

struct StandardButtonView: View {
    var disabled: Bool = false
    let text: String
    let style: StandardButtonStyle
    
    var body: some View {
        var button = AnytypeText(text, style: .headline)
                .padding(.all)
                .foregroundColor(disabled ? .textSecondary : style.textColor())
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(style.backgroundColor())
                .cornerRadius(8.0)
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
        VStack {
            StandardButton(disabled: false ,text: "Button text", style: .secondary, action: {})
            StandardButton(disabled: true ,text: "Button text", style: .secondary, action: {})
            StandardButton(disabled: false ,text: "Button text", style: .primary, action: {})
            StandardButton(disabled: true ,text: "Button text", style: .primary, action: {})
        }.padding()
    }
}

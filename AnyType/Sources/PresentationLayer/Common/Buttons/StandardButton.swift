import SwiftUI

typealias StandardButtonAction = () -> Void

enum StandardButtonStyle {
    case yellow
    case white
    
    func backgroundColor() -> Color {
        switch self {
        case .white:
            return Color.white
        case .yellow:
            return ColorPalette.yellow
        }
    }
    
    func textColor() -> Color {
        switch self {
        case .white:
            return Color.black
        case .yellow:
            return Color.white
        }
    }
    
    func borderColor() -> Color? {
        switch self {
        case .white:
            return ColorPalette.grayText
        case .yellow:
            return nil
        }
    }
}

struct StandardButton: View {
    var disabled: Bool
    var text: String
    var style: StandardButtonStyle
    var action: StandardButtonAction
    
    var body: some View {
        var button = Button(action: {
            self.action()
        }) {
            Text(text).font(.headline)
                .padding(.all)
                .foregroundColor(disabled ? Color.gray : style.textColor())
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

#if DEBUG
struct StandardButton_Previews: PreviewProvider {
    static var previews: some View {
        StandardButton(disabled: false ,text: "Standard button", style: .white, action: {})
    }
}
#endif

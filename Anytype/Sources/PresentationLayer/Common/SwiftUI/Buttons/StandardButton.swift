import SwiftUI


typealias StandardButtonAction = () -> Void

struct StandardButtonData {
    var disabled: Bool = false
    let text: String
    let style: StandardButtonStyle
    let action: StandardButtonAction
}

struct StandardButton: View {
    var disabled: Bool = false
    let text: String
    let style: StandardButtonStyle
    let action: StandardButtonAction
    
    var body: some View {
        Button(action:action) {
            StandardButtonView(disabled: disabled, text: text, style: style)
        }
        .disabled(disabled)
    }
}

extension StandardButton {
    init(data: StandardButtonData) {
        self.init(
            disabled: data.disabled,
            text: data.text,
            style: data.style,
            action: data.action
        )
    }
}

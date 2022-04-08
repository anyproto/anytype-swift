import SwiftUI

typealias StandardButtonAction = () -> Void

struct StandardButton: View {
    let disabled: Bool
    let inProgress: Bool
    let text: String
    let style: StandardButtonStyle
    let action: StandardButtonAction
    
    init(
        disabled: Bool = false,
        inProgress: Bool = false,
        text: String,
        style: StandardButtonStyle,
        action: @escaping StandardButtonAction
    ) {
        self.disabled = disabled
        self.inProgress = inProgress
        self.text = text
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            StandardButtonView(disabled: disabled, inProgress: inProgress, text: text, style: style)
        }
        .disabled(disabled)
        .buttonStyle(ShrinkingButtonStyle())
    }
}

extension StandardButton {
    
    init(model: StandardButtonModel) {
        self.init(
            disabled: model.disabled,
            inProgress: model.inProgress,
            text: model.text,
            style: model.style,
            action: model.action
        )
    }
    
}

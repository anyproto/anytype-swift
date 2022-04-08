import SwiftUI

typealias StandardButtonAction = () -> Void

struct StandardButtonData {
    let disabled: Bool
    let inProgress: Bool
    let text: String
    let style: StandardButtonStyle
    let action: StandardButtonAction
    
    init(disabled: Bool = false, inProgress: Bool = false, text: String, style: StandardButtonStyle, action: @escaping StandardButtonAction) {
        self.disabled = disabled
        self.inProgress = inProgress
        self.text = text
        self.style = style
        self.action = action
    }
}

struct StandardButton: View {
    var disabled: Bool = false
    var inProgress: Bool = false
    let text: String
    let style: StandardButtonStyle
    let action: StandardButtonAction
    
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
    init(data: StandardButtonData) {
        self.init(
            disabled: data.disabled,
            inProgress: data.inProgress,
            text: data.text,
            style: data.style,
            action: data.action
        )
    }
}

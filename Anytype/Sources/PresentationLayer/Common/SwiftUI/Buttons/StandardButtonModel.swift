import Foundation

struct StandardButtonModel {
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
}

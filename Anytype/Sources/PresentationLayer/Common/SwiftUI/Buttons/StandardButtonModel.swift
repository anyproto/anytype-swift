import Foundation

struct StandardButtonModel {
    let text: String
    let disabled: Bool
    let inProgress: Bool
    let style: StandardButtonStyle
    let action: StandardButtonAction
    
    init(
        text: String,
        disabled: Bool = false,
        inProgress: Bool = false,
        style: StandardButtonStyle,
        action: @escaping StandardButtonAction
    ) {
        self.text = text
        self.disabled = disabled
        self.inProgress = inProgress
        self.style = style
        self.action = action
    }
}

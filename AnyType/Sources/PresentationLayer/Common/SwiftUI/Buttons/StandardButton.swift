import SwiftUI


typealias StandardButtonAction = () -> Void

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

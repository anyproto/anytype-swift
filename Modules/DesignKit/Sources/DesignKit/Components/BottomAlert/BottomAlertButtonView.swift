import Foundation
import SwiftUI
import AnytypeCore

public struct BottomAlertButton {
    
    public enum Style {
        case primary
        case secondary
        case warning
    }
    
    public var text: String
    public var style: Style
    public var disable = false
    public var action: () async throws -> Void
    
    public init(text: String, style: Style, disable: Bool = false, action: @escaping () async throws -> Void) {
        self.text = text
        self.style = style
        self.disable = disable
        self.action = action
    }
    
    fileprivate var standartStyle: StandardButtonStyle {
        switch style {
        case .primary:
            return .primaryLarge
        case .secondary:
            return .secondaryLarge
        case .warning:
            return .warningLarge
        }
    }
}



struct BottomAlertButtonView: View {
    
    let buttons: [BottomAlertButton]
    
    var body: some View {
        AsyncStandardButtonGroup {
            buttonsView
        }
    }
    
    @ViewBuilder
    private var buttonsView: some View {
        BottomAlertButttonStack {
            ForEach(0..<buttons.count, id: \.self) { index in
                let button = buttons[index]
                AsyncStandardButton(
                    button.text,
                    style: button.standartStyle,
                    action: button.action
                )
                .disabled(button.disable)
            }
        }
    }
}


extension BottomAlertButtonView {
    init(@ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]) {
        self.buttons = buttons()
    }
}


import Foundation
import SwiftUI
import AnytypeCore

struct BottomAlertButton {
    
    enum Style {
        case primary
        case secondary
        case warning
    }
    
    var text: String
    var style: Style
    var action: () async throws -> Void
    
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
        if #available(iOS 16.0, *) {
            BottomAlertButttonStack {
                ForEach(0..<buttons.count, id: \.self) { index in
                    let button = buttons[index]
                    AsyncStandardButton(
                        text: button.text,
                        style: button.standartStyle,
                        action: button.action
                    )
                }
            }
        } else {
            VStack(spacing: 10) {
                ForEach(0..<buttons.count, id: \.self) { index in
                    let button = buttons[index]
                    AsyncStandardButton(
                        text: button.text,
                        style: button.standartStyle,
                        action: button.action
                    )
                }
            }
        }
        
    }
}


extension BottomAlertButtonView {
    init(@ArrayBuilder<BottomAlertButton> buttons: () -> [BottomAlertButton]) {
        self.buttons = buttons()
    }
}


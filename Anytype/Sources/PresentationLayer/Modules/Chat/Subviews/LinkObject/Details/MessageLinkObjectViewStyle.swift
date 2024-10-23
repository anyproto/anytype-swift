import Foundation
import SwiftUI

enum MessageLinkObjectViewStyle {
    case input
    case listMy
    case listOther
}

struct MessageLinkObjectViewStyleConfig {
    let borderColor: Color
    let shadowColor: Color
}

extension MessageLinkObjectViewStyle {
    
    var config: MessageLinkObjectViewStyleConfig {
        switch self {
        case .input:
            MessageLinkObjectViewStyleConfig(
                borderColor: .Shape.tertiary,
                shadowColor: .Additional.messageInputShadow
            )
        case .listMy:
            MessageLinkObjectViewStyleConfig(
                borderColor: .Shape.transperentSecondary,
                shadowColor: .clear
            )
        case .listOther:
            MessageLinkObjectViewStyleConfig(
                borderColor: .Shape.tertiary,
                shadowColor: .clear
            )
        }
    }
}

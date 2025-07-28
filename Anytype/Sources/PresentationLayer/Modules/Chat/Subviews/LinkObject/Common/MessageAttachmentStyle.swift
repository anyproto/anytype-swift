import Foundation
import SwiftUI

enum MessageAttachmentStyle {
    case messageOther
    case messageYour
    case chatInput
}

extension MessageAttachmentStyle {
    var titleColor: Color {
        switch self {
        case .messageOther:
            .Text.primary
        case .messageYour:
            .Text.white
        case .chatInput:
            .Text.primary
        }
    }
    
    var descriptionColor: Color {
        switch self {
        case .messageOther:
            .Control.transparentSecondary
        case .messageYour:
            .Background.Chat.whiteTransparent
        case .chatInput:
            .Text.secondary
        }
    }
}

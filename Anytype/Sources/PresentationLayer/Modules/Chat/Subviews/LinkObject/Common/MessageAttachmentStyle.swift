import Foundation
import SwiftUI

enum MessageAttachmentStyle {
    case messageOther
    case messageYour
    case chatInput
}

extension MessageAttachmentStyle {
    var titleColor: UIColor {
        switch self {
        case .messageOther:
            .Text.primary
        case .messageYour:
            .Text.white
        case .chatInput:
            .Text.primary
        }
    }
    
    var descriptionColor: UIColor {
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

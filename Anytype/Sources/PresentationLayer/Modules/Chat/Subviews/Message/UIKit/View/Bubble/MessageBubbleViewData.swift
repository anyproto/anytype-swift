import UIKit

struct MessageBubbleViewData: Equatable, Hashable {
    let messageId: String
    let messageText: NSAttributedString
    let linkedObjects: MessageBubbleAttachments?
    let position: MessageHorizontalPosition
    let messageYourBackgroundColor: UIColor
}

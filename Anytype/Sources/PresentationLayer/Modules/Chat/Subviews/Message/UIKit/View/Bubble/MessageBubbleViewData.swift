import UIKit
import StoredHashMacro

@StoredHash
struct MessageBubbleViewData: Equatable, Hashable {
    let messageText: NSAttributedString
    let linkedObjects: MessageBubbleAttachments?
    let position: MessageHorizontalPosition
    let messageYourBackgroundColor: UIColor
    
    // Actions
    let canAddReaction: Bool
    let canReply: Bool
    let canEdit: Bool
    let canDelete: Bool
}

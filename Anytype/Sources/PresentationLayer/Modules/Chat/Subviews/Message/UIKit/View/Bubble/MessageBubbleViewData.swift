import UIKit

struct MessageBubbleViewData: Equatable {
    let messageText: NSAttributedString
    let linkedObjects: MessageLinkedObjectsLayout?
    let position: MessageHorizontalPosition
    let messageYourBackgroundColor: UIColor
}

extension MessageBubbleViewData {
    init(data: MessageViewData) {
        let color = UIColor.black.withAlphaComponent(0.5)
        self.messageText = NSAttributedString(data.messageString)
        self.linkedObjects = data.linkedObjects
        self.position = data.position
        // TODO: Fix it
        self.messageYourBackgroundColor = color
    }
}

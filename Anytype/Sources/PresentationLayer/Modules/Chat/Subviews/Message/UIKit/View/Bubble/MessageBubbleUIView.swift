import UIKit
import Cache

struct MessageBubbleViewData: Equatable {
    let messageText: NSAttributedString
    let linkedObjects: MessageLinkedObjectsLayout?
    let position: MessageHorizontalPosition
    let messageYourBackgroundColor: UIColor
}

extension MessageBubbleViewData {
    init(data: MessageViewData) {
        self.messageText = NSAttributedString(data.messageString)
        self.linkedObjects = data.linkedObjects
        self.position = data.position
        // TODO: Fix it
        self.messageYourBackgroundColor = .black.withAlphaComponent(0.5)
    }
}

final class MessageBubbleUIView: UIView {
    
    // MARK: - Private properties
    
    private lazy var textView = MessageTextUIView()
    private lazy var gridAttachments = MessageGridAttachmentUIViewContainer()
    private lazy var bigBookmarkView = MessageBigBookmarkUIView()
    private lazy var listAttachments = MessageListAttachmentsUIView()
    
    // MARK: - Public properties
    
    var data: MessageBubbleViewData? {
        didSet {
            if data != oldValue {
                updateView()
            }
        }
    }
    
    var layout: MessageBubbleLayout? {
        didSet {
            if layout != oldValue {
                textView.layout = layout?.textLayout
                gridAttachments.layout = layout?.gridAttachmentsLayout
                bigBookmarkView.layout = layout?.bigBookmarkLayout
                listAttachments.layout = layout?.listAttachmentsLayout
                setNeedsLayout()
            }
        }
    }
    
    // MARK: - Pulic
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout else { return }
        
        textView.frame = layout.textFrame ?? .zero
        gridAttachments.frame = layout.gridAttachmentsFrame ?? .zero
        bigBookmarkView.frame = layout.bigBookmarkFrame ?? .zero
        listAttachments.frame = layout.listAttachmentsFrame ?? .zero
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return layout?.bubbleSize ?? .zero
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let data else { return }
        
        if data.messageText.string.isNotEmpty {
            textView.text = data.messageText
            addSubview(textView)
        } else {
            textView.removeFromSuperview()
        }
        
        switch data.linkedObjects {
        case .list(let items):
            listAttachments.data = MessageListAttachmentsViewData(objects: items, position: data.position)
            addSubview(listAttachments)
            bigBookmarkView.removeFromSuperview()
            gridAttachments.removeFromSuperview()
        case .grid(let objects):
            gridAttachments.objects = objects
            addSubview(gridAttachments)
            bigBookmarkView.removeFromSuperview()
            listAttachments.removeFromSuperview()
        case .bookmark(let objectDetails):
            bigBookmarkView.data = MessageBigBookmarkViewData(details: objectDetails, position: data.position)
            addSubview(bigBookmarkView)
            gridAttachments.removeFromSuperview()
            listAttachments.removeFromSuperview()
        case nil:
            bigBookmarkView.removeFromSuperview()
            gridAttachments.removeFromSuperview()
            listAttachments.removeFromSuperview()
        }
            
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = data.position.isRight ? data.messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
}

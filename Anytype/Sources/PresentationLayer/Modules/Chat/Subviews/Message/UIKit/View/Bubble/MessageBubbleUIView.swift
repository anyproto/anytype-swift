import UIKit
import Cache

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
                updateLayout()
            }
        }
    }
    
    weak var output: (any MessageModuleOutput)? {
        didSet {
            bigBookmarkView.output = output
            gridAttachments.output = output
            listAttachments.output = output
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
        
        textView.text = data.messageText
        
        switch data.linkedObjects {
        case .list(let data):
            listAttachments.data = data
        case .grid(let objects):
            gridAttachments.objects = objects
        case .bookmark(let data):
            bigBookmarkView.data = data
        case nil:
            break
        }
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = data.position.isRight ? data.messageYourBackgroundColor : .Background.Chat.bubbleSomeones
    }
    
    private func updateLayout() {
        textView.layout = layout?.textLayout
        gridAttachments.layout = layout?.gridAttachmentsLayout
        bigBookmarkView.layout = layout?.bigBookmarkLayout
        listAttachments.layout = layout?.listAttachmentsLayout
        
        textView.addTo(parent: self, frame: layout?.textFrame)
        gridAttachments.addTo(parent: self, frame: layout?.gridAttachmentsFrame)
        bigBookmarkView.addTo(parent: self, frame: layout?.bigBookmarkFrame)
        listAttachments.addTo(parent: self, frame: layout?.listAttachmentsFrame)
    }
}

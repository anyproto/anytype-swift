import UIKit
import Cache

final class MessageBubbleUIView: UIView, UIContextMenuInteractionDelegate {
    
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
    
    var onTapAddReaction: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapReplyTo: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapDelete: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapCopyPlainText: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapEditMessage: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapUnread: ((_ data: MessageBubbleViewData) -> Void)?
    var onTapAttachment: ((_ data: MessageBubbleViewData, _ objectId: String) -> Void)?
    
    // MARK: - Pulic
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // MARK: - UIContextMenuInteractionDelegate
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let data else { return nil }

        let actions: [UIMenuElement] = .builder {
            if data.canAddReaction {
                UIMenu(title: "", options: .displayInline, children: [
                    UIAction(
                        title: Loc.Message.Action.addReaction,
                        image: UIImage(systemName: "face.smiling")
                    ) { [weak self] _ in
                        self?.onTapAddReaction?(data)
                    }
                ])
            }
            
            #if DEBUG || RELEASE_NIGHTLY
            UIAction(
                title: Loc.Message.Action.unread,
            ) { [weak self] _ in
                self?.onTapUnread?(data)
            }
            #endif
            
            if data.canReply {
                UIAction(
                    title: Loc.Message.Action.reply,
                    image: UIImage(systemName: "arrowshape.turn.up.left")
                ) { [weak self] _ in
                    self?.onTapReplyTo?(data)
                }
            }
            
            if data.messageText.string.isNotEmpty {
                UIAction(
                    title: Loc.Message.Action.copyPlainText,
                    image: UIImage(systemName: "doc.on.doc")
                ) { [weak self] _ in
                    self?.onTapCopyPlainText?(data)
                }
            }
            
            if data.canEdit {
                UIAction(
                    title: Loc.edit,
                    image: UIImage(systemName: "pencil")
                ) { [weak self] _ in
                    self?.onTapEditMessage?(data)
                }
            }
            
            if data.canDelete {
                UIAction(
                    title: Loc.delete,
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.onTapDelete?(data)
                }
            }
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            return UIMenu(title: "", children: actions)
        }
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
    
    private func setupActions() {
        
        gridAttachments.onTapAttachment = { [weak self] objectId in
            guard let self, let data else { return }
            onTapAttachment?(data, objectId)
        }
        
        bigBookmarkView.onTap = { [weak self] bookmark in
            guard let self, let data else { return }
            onTapAttachment?(data, bookmark.objectId)
        }
        
        listAttachments.onTapAttachment = { [weak self] objectId in
            guard let self, let data else { return }
            onTapAttachment?(data, objectId)
        }
    }
}

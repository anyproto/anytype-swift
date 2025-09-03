import UIKit
import Cache

final class MessageUIView: UIView, UIContentView {
    
    private lazy var iconView = IconViewUIKit()
    private lazy var bubbleView = MessageBubbleUIView()
    private lazy var reactionsView = MessageReactionListUIView()
    private lazy var replyView = MessageReplyUIView()
    
    private var messageConfiguration: MessageConfiguration {
        didSet {
            if messageConfiguration.data != oldValue.data {
                updateData()
            }
            if messageConfiguration.layout != oldValue.layout {
                updateLayout()
            }
        }
    }
    
    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? MessageConfiguration else { return }
            messageConfiguration = configuration
        }
    }
    
    init(configuration: MessageConfiguration) {
        self.configuration = configuration
        self.messageConfiguration = configuration
        super.init(frame:.zero)
        setupOutput()
        updateData()
        updateLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func updateData() {
        let data = messageConfiguration.data
        bubbleView.data = data.bubble
        iconView.icon = data.authorIcon
        replyView.data = data.reply
        reactionsView.data = data.reactions
    }
    
    private func updateLayout() {
        let layout = messageConfiguration.layout
        bubbleView.layout = layout.bubbleLayout
        reactionsView.layout = layout.reactionsLayout
        replyView.layout = layout.replyLayout
        
        iconView.addTo(parent: self, frame: layout.iconFrame)
        bubbleView.addTo(parent: self, frame: layout.bubbleFrame)
        reactionsView.addTo(parent: self, frame: layout.reactionsFrame)
        replyView.addTo(parent: self, frame: layout.replyFrame)
    }
    
    private func setupOutput() {
        reactionsView.onTapReaction = { [weak self] emoji in
            guard let self else { return }
            messageConfiguration.output?.didTapOnReaction(message: messageConfiguration.data, emoji: emoji)
        }
        
        reactionsView.onLongTapReaction = { [weak self] reaction in
            guard let self else { return }
            messageConfiguration.output?.didLongTapOnReaction(message: messageConfiguration.data, reaction: reaction)
        }
        
        reactionsView.onTapAddReaction = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectAddReaction(message: messageConfiguration.data)
        }
        
        bubbleView.onTapAddReaction = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectAddReaction(message: messageConfiguration.data)
        }
        
        bubbleView.onTapReplyTo = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectReplyTo(message: messageConfiguration.data)
        }
        
        bubbleView.onTapDelete = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectDelete(message: messageConfiguration.data)
        }
        
        bubbleView.onTapCopyPlainText = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectCopyPlainText(message: messageConfiguration.data)
        }
        
        bubbleView.onTapEditMessage = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectEdit(message: messageConfiguration.data)
        }
        
        bubbleView.onTapUnread = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectUnread(message: messageConfiguration.data)
        }
        
        bubbleView.onTapAttachment = { [weak self] _, objectId in
            guard let self else { return }
            messageConfiguration.output?.didSelectAttachment(message: messageConfiguration.data, objectId: objectId)
        }
        
        replyView.onTap = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectReply(message: messageConfiguration.data)
        }
    }
}

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
            messageConfiguration.output?.didTapOnReaction(data: messageConfiguration.data, emoji: emoji)
        }
        
        reactionsView.onLongTapReaction = { [weak self] reaction in
            guard let self else { return }
            messageConfiguration.output?.didLongTapOnReaction(data: messageConfiguration.data, reaction: reaction)
        }
        
        reactionsView.onTapAddReaction = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectAddReaction(data: messageConfiguration.data)
        }
        
        bubbleView.onTapAddReaction = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectAddReaction(data: messageConfiguration.data)
        }
        
        bubbleView.onTapReplyTo = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectReplyTo(data: messageConfiguration.data)
        }
        
        replyView.onTap = { [weak self] _ in
            guard let self else { return }
            messageConfiguration.output?.didSelectReplyMessage(data: messageConfiguration.data)
        }
    }
}

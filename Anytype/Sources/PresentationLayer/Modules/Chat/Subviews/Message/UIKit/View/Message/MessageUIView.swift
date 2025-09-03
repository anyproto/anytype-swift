import UIKit
import Cache

final class MessageUIView: UIView, UIContentView {
    
    private lazy var iconView = IconViewUIKit()
    private lazy var bubbleView = MessageBubbleUIView()
    private lazy var reactionsView = MessageReactionListUIView()
    private lazy var replyView = MessageReplyUIView()
    
    private var data: MesageUIViewData {
        didSet {
            if data != oldValue {
                updateData()
            }
        }
    }
    
    private var layout: MessageLayout {
        didSet {
            if layout != oldValue {
                updateLayout()
            }
        }
    }
    
    var configuration: any UIContentConfiguration {
        didSet {
            guard let configuration = configuration as? MessageConfiguration else { return }
            data = configuration.model
            layout = configuration.layout
        }
    }
    
    init(configuration: MessageConfiguration) {
        self.configuration = configuration
        self.data = configuration.model
        self.layout = configuration.layout
        super.init(frame:.zero)
        updateData()
        updateLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func updateData() {
        bubbleView.data = data.bubble
        iconView.icon = data.authorIcon
        replyView.data = data.reply
        reactionsView.data = data.reactions
    }
    
    private func updateLayout() {
        bubbleView.layout = layout.bubbleLayout
        reactionsView.layout = layout.reactionsLayout
        replyView.layout = layout.replyLayout
        
        iconView.addTo(parent: self, frame: layout.iconFrame)
        bubbleView.addTo(parent: self, frame: layout.bubbleFrame)
        reactionsView.addTo(parent: self, frame: layout.reactionsFrame)
        replyView.addTo(parent: self, frame: layout.replyFrame)
    }
}

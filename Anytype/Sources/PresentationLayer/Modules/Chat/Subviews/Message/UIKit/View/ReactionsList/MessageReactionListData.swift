import Foundation

struct MessageReactionListData: Equatable {
    let reactions: [MessageReactionData]
    let canAddReaction: Bool
    let position: MessageHorizontalPosition
    
    var showReactions: Bool {
        reactions.isNotEmpty
    }
}

extension MessageReactionListData {
    init(data: MessageViewData) {
        self = MessageReactionListData(
            reactions: data.reactions.map {
                MessageReactionData(
                    emoji: $0.emoji,
                    content: $0.content,
                    selected: $0.selected,
                    position: $0.position,
                    messageYourBackgroundColor: .black.withAlphaComponent(0.5)
                )
            },
            canAddReaction: data.canAddReaction,
            position: data.position
        )
    }
}

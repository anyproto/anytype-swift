import Foundation

struct MessageLayout: Equatable {
    let cellSize: CGSize
    let iconFrame: CGRect?
    let bubbleFrame: CGRect?
    let bubbleLayout: MessageBubbleLayout?
    let reactionsFrame: CGRect?
    let reactionsLayout: MessageReactionListLayout?
}

import Foundation

struct UnreadBadge: Hashable, Sendable {
    enum Style: Hashable, Sendable {
        case blue
        case grey
    }

    struct UnreadCounter: Hashable, Sendable {
        let messageCount: Int
        let style: Style
    }

    let unreadCounter: UnreadCounter?
    let hasMention: Bool

    var appIconContribution: Int {
        guard let counter = unreadCounter, counter.style == .blue else { return 0 }
        return counter.messageCount
    }
}

import Foundation
import Services
import StoredHashMacro

@StoredHash
struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable, Hashable {
    let space: ParticipantSpaceViewData
    let latestPreview: ChatMessagePreview
    /// Sort key: the latest message's date or, while this space's chat previews are still
    /// loading, the date remembered from the previous launch. See `SpaceHubSpacesStorage`.
    let lastMessageDate: Date?
    let totalUnreadCounter: Int
    let totalMentionCounter: Int
    let hasUnreadReactions: Bool
    let unreadCounterStyle: CounterViewStyle
    let mentionCounterStyle: BadgeStyle
    let reactionStyle: BadgeStyle
    let unreadPreviews: [ChatMessagePreview]
    let unreadDiscussionParents: [DiscussionUnreadParent]

    var id: String { space.id }

    var spaceView: SpaceView { space.spaceView }

    var hasCounters: Bool { totalUnreadCounter > 0 || totalMentionCounter > 0 || hasUnreadReactions }
}

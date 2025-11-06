import Services
import StoredHashMacro

@StoredHash
struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable, Hashable {
    let space: ParticipantSpaceViewData
    let latestPreview: ChatMessagePreview
    let totalUnreadCounter: Int
    let totalMentionCounter: Int

    var id: String { space.id }

    var spaceView: SpaceView { space.spaceView }

    var hasCounters: Bool { totalUnreadCounter > 0 || totalMentionCounter > 0 }

    func updated(latestPreview: ChatMessagePreview, totalUnread: Int, totalMentions: Int) -> Self {
        ParticipantSpaceViewDataWithPreview(
            space: space,
            latestPreview: latestPreview,
            totalUnreadCounter: totalUnread,
            totalMentionCounter: totalMentions
        )
    }
}

extension ParticipantSpaceViewDataWithPreview {
    init(space: ParticipantSpaceViewData) {
        self.init(
            space: space,
            latestPreview: ChatMessagePreview(spaceId: space.id, chatId: space.spaceView.chatId),
            totalUnreadCounter: 0,
            totalMentionCounter: 0
        )
    }
}

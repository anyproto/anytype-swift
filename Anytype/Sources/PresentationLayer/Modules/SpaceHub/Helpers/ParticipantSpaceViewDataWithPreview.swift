import Services
import StoredHashMacro

@StoredHash
struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable, Hashable {
    let space: ParticipantSpaceViewData
    let preview: ChatMessagePreview
    
    var id: String { space.id }
    
    var spaceView: SpaceView { space.spaceView }
    
    var hasCounters: Bool { preview.unreadCounter > 0 || preview.mentionCounter > 0 }
    
    func updated(preview: ChatMessagePreview) -> Self {
        ParticipantSpaceViewDataWithPreview(space: space, preview: preview)
    }
}

extension ParticipantSpaceViewDataWithPreview {
    init(space: ParticipantSpaceViewData) {
        self.space = space
        self.preview = ChatMessagePreview(spaceId: space.id, chatId: space.spaceView.chatId)
    }
}

struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable {
    let space: ParticipantSpaceViewData
    let unreadCount: Int
    let mentionsCount: Int
    // TBD: More preview data here
    let lastMessage: String
    
    var id: String { "\(space.id)_\(unreadCount)_\(mentionsCount)_\(lastMessage)"  }
    
    var spaceView: SpaceView { space.spaceView }
    
    var haveCounters: Bool { unreadCount > 0 || mentionsCount > 0 }
    
    func updated(unreadCount: Int, mentionsCount: Int, lastMessage: String) -> Self {
        ParticipantSpaceViewDataWithPreview(
            space: space,
            unreadCount: unreadCount,
            mentionsCount: mentionsCount,
            lastMessage: lastMessage
        )
    }
}

extension ParticipantSpaceViewDataWithPreview {
    init(space: ParticipantSpaceViewData) {
        self.space = space
        self.unreadCount = 0
        self.mentionsCount = 0
        self.lastMessage = ""
    }
}

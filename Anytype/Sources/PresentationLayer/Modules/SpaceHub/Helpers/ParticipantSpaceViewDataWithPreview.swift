struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable {
    let space: ParticipantSpaceViewData
    let unreadCount: Int
    let mentionsCount: Int
    // TBD: More preview data here
    
    var id: String { "\(space.id)_\(unreadCount)_\(mentionsCount)"  }
    
    var spaceView: SpaceView { space.spaceView }
    
    func updated(unreadCount: Int, mentionsCount: Int) -> Self {
        ParticipantSpaceViewDataWithPreview(space: space, unreadCount: unreadCount, mentionsCount: mentionsCount)
    }
}

extension ParticipantSpaceViewDataWithPreview {
    init(space: ParticipantSpaceViewData) {
        self.space = space
        self.unreadCount = 0
        self.mentionsCount = 0
    }
}

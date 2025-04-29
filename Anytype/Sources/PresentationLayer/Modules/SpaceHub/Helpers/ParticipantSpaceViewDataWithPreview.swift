struct ParticipantSpaceViewDataWithPreview: Equatable, Identifiable {
    let space: ParticipantSpaceViewData
    let unreadCount: Int
    // TBD: More preview data here
    
    var id: String { "\(space.id)_\(unreadCount)"  }
    
    var spaceView: SpaceView { space.spaceView }
    
    func updated(unreadCount: Int) -> Self {
        ParticipantSpaceViewDataWithPreview(space: space, unreadCount: unreadCount)
    }
}

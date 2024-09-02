extension SpaceView {
    static func mock(id: Int) -> SpaceView {
        mock(id: "\(id)")
    }
    
    static func mock(id: String) -> SpaceView {
        SpaceView(
            id: id,
            name: "Name \(id)",
            objectIconImage: .object(.space(.gradient(.random))),
            targetSpaceId: "Target\(id)",
            createdDate: .yesterday,
            accountStatus: .ok,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            sharedSpacesLimit: nil
        )
    }
}

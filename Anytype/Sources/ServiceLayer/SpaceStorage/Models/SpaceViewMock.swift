import Services

extension SpaceView {
    static func mock(id: Int) -> SpaceView {
        mock(id: "\(id)")
    }
    
    static func mock(id: String) -> SpaceView {
        SpaceView(
            id: id,
            name: "Name \(id)",
            description: "Desciption \(id)",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: "Target\(id)",
            createdDate: .yesterday,
            accountStatus: .ok,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            isPinned: false,
            uxType: .data
        )
    }
}

public extension ObjectIcon.Space {
    static var mock: ObjectIcon.Space {
        .name(name: Loc.Object.Title.placeholder, iconOption: 1)
    }
}

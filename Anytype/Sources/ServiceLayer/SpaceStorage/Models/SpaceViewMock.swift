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
            uxType: .data,
            unreadMessagesCount: 0
        )
    }
}

public extension ObjectIcon.Space {
    static var mock: ObjectIcon.Space {
        .name(name: Loc.untitled, iconOption: 1)
    }
}

import Services
import Foundation

extension SpaceView {
    static func mock(id: Int) -> SpaceView {
        mock(id: "\(id)")
    }
    
    static func mock(
        id: String = UUID().uuidString,
        accountStatus: SpaceStatus? = .allCases.randomElement(),
        localStatus: SpaceStatus? = .allCases.randomElement()
    ) -> SpaceView {
        return SpaceView(
            id: id,
            name: "Name \(id)",
            description: "Desciption \(id)",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: id,
            createdDate: .yesterday,
            joinDate: .distantPast,
            accountStatus: accountStatus,
            localStatus: localStatus,
            spaceAccessType: .allCases.randomElement(),
            readersLimit: nil,
            writersLimit: nil,
            chatId: Bool.random() ? "123" : "",
            spaceOrder: "",
            uxType: .allCases.randomElement()!,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: .allCases.randomElement()!
        )
    }
}

public extension ObjectIcon.Space {
    static var mock: ObjectIcon.Space {
        .name(name: Loc.untitled, iconOption: 1, circular: true)
    }
}

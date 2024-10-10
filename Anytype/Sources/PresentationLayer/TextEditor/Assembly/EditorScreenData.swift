import Services
import AnytypeCore

enum EditorScreenData: Hashable, Codable {
    case favorites(homeObjectId: String, spaceId: String)
    case recentEdit(spaceId: String)
    case recentOpen(spaceId: String)
    case sets(spaceId: String)
    case collections(spaceId: String)
    case bin(spaceId: String)
    case chats(spaceId: String)
    case page(EditorPageObject)
    case set(EditorSetObject)
    case discussion(EditorDiscussionObject)
    case allContent(spaceId: String)
}

struct EditorPageObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    let mode: DocumentMode
    var blockId: String?
    let usecase: ObjectHeaderEmptyUsecase
    
    init(
        objectId: String,
        spaceId: String,
        mode: DocumentMode = .handling,
        blockId: String? = nil,
        usecase: ObjectHeaderEmptyUsecase = .full
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.mode = mode
        self.blockId = blockId
        self.usecase = usecase
    }
}

struct EditorSetObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    let activeViewId: String?
    var inline: EditorInlineSetObject?
    let mode: DocumentMode
    let usecase: ObjectHeaderEmptyUsecase
    
    init(
        objectId: String,
        spaceId: String,
        activeViewId: String? = nil,
        inline: EditorInlineSetObject? = nil,
        mode: DocumentMode = .handling,
        usecase: ObjectHeaderEmptyUsecase = .full
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.activeViewId = activeViewId
        self.inline = inline
        self.mode = mode
        self.usecase = usecase
    }
}

struct EditorDiscussionObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
}

struct EditorInlineSetObject: Hashable, Codable {
    let blockId: String
    let targetObjectID: String
}

enum EditorViewType {
    case page
    case set
    case discussion
}

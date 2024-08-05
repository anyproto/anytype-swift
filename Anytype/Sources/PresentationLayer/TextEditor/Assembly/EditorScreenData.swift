import Services
import AnytypeCore

enum EditorScreenData: Hashable, Codable {
    case favorites
    case recentEdit
    case recentOpen
    case sets
    case collections
    case bin
    case page(EditorPageObject)
    case set(EditorSetObject)
    case discussion(EditorDiscussionObject)
}

struct EditorPageObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    let mode: DocumentMode
    var blockId: String?
    let usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase
    
    init(
        objectId: String,
        spaceId: String,
        mode: DocumentMode = .handling,
        blockId: String? = nil,
        usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase = .editor
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
    
    init(
        objectId: String,
        spaceId: String,
        activeViewId: String? = nil,
        inline: EditorInlineSetObject? = nil,
        mode: DocumentMode = .handling
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.activeViewId = activeViewId
        self.inline = inline
        self.mode = mode
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
}

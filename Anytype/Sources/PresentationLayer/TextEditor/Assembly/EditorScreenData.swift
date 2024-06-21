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
}

struct EditorPageObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    let isOpenedForPreview: Bool
    var blockId: String?
    let usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase
    
    init(
        objectId: String,
        spaceId: String,
        isOpenedForPreview: Bool,
        blockId: String? = nil,
        usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase = .editor
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.isOpenedForPreview = isOpenedForPreview
        self.blockId = blockId
        self.usecase = usecase
    }
}

struct EditorSetObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    var inline: EditorInlineSetObject?
    
    init(
        objectId: String,
        spaceId: String,
        inline: EditorInlineSetObject? = nil
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.inline = inline
    }
}

struct EditorInlineSetObject: Hashable, Codable {
    let blockId: String
    let targetObjectID: String
}

enum EditorViewType {
    case page
    case set
}

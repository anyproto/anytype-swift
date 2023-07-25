import Services
import AnytypeCore

enum EditorScreenData: Hashable, Codable {
    case favorites
    case recent
    case sets
    case collections
    case bin
    case page(EditorPageObject)
    case set(EditorSetObject)
}

struct EditorPageObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    let isSupportedForEdit: Bool
    let isOpenedForPreview: Bool
    let shouldShowTemplatesOptions: Bool
    
    init(
        objectId: String,
        spaceId: String,
        isSupportedForEdit: Bool,
        isOpenedForPreview: Bool,
        shouldShowTemplatesOptions: Bool = true
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.isSupportedForEdit = isSupportedForEdit
        self.isOpenedForPreview = isOpenedForPreview
        self.shouldShowTemplatesOptions = shouldShowTemplatesOptions
    }
}

struct EditorSetObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
    var inline: EditorInlineSetObject?
    let isSupportedForEdit: Bool
    
    init(
        objectId: String,
        spaceId: String,
        inline: EditorInlineSetObject? = nil,
        isSupportedForEdit: Bool
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.inline = inline
        self.isSupportedForEdit = isSupportedForEdit
    }
}

struct EditorInlineSetObject: Hashable, Codable {
    let blockId: BlockId
    let targetObjectID: String
}

enum EditorViewType {
    case page
    case set
}

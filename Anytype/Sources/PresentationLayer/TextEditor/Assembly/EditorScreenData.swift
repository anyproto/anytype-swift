import Services
import Foundation
import AnytypeCore

enum EditorScreenData: Hashable, Codable, Equatable, Identifiable {
    // Anytype widget screens
    case favorites(homeObjectId: String, spaceId: String)
    case recentEdit(spaceId: String)
    case recentOpen(spaceId: String)
    case sets(spaceId: String)
    case collections(spaceId: String)
    case bin(spaceId: String)
    
    // Object
    case page(EditorPageObject)
    case list(EditorListObject)
    case simpleSet(EditorSimpleSetObject)
    
    case date(EditorDateObject)
    case type(EditorTypeObject)
    
    case allObjects(spaceId: String)
    
    var id: Int {
        hashValue
    }
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

struct EditorListObject: Hashable, Codable {
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

struct EditorDateObject: Hashable, Codable {
    let date: Date?
    let spaceId: String
}

struct EditorInlineSetObject: Hashable, Codable {
    let blockId: String
    let targetObjectID: String
}

struct EditorTypeObject: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String
    
    var id: String { spaceId + objectId } 
}

struct EditorSimpleSetObject: Hashable, Codable {
    let objectId: String
    let spaceId: String
}

extension EditorScreenData {
    var isSimpleSet: Bool {
        switch self {
        case .simpleSet:
            return true
        default:
            return false
        }
    }
}

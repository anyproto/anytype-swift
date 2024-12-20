import Foundation
import Services

// MARK: - Init helpers

extension EditorScreenData {
    init(details: ObjectDetails, mode: DocumentMode = .handling, blockId: String? = nil, activeViewId: String? = nil) {
        switch details.editorViewType {
        case .page:
            self = .page(EditorPageObject(
                details: details,
                mode: mode,
                blockId: blockId
            ))
        case .list:
            self = .list(EditorListObject(
                details: details,
                activeViewId: activeViewId,
                mode: mode
            ))
        case .date:
            self = .date(EditorDateObject(date: details.timestamp, spaceId: details.spaceId))
        case .type:
            self = .type(EditorTypeObject(objectId: details.id, spaceId: details.spaceId))
        }
    }
}

extension EditorPageObject {
    init(
        details: ObjectDetails,
        mode: DocumentMode = .handling,
        blockId: String? = nil,
        usecase: ObjectHeaderEmptyUsecase = .full
    ) {
        self.objectId = details.id
        self.spaceId = details.spaceId
        self.mode = mode
        self.blockId = blockId
        self.usecase = usecase
    }
}

extension EditorListObject {
    init(
        details: ObjectDetails,
        activeViewId: String? = nil,
        mode: DocumentMode = .handling,
        usecase: ObjectHeaderEmptyUsecase = .full
    ) {
        self.objectId = details.id
        self.spaceId = details.spaceId
        self.activeViewId = activeViewId
        self.inline = nil
        self.mode = mode
        self.usecase = usecase
    }
}

extension ObjectDetails {
    func editorScreenData() -> EditorScreenData {
        return EditorScreenData(details: self)
    }
}

// MARK: Read fields helpers

extension EditorScreenData {
   
    var objectId: String? {
        switch self {
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin, .allContent, .date:
            return nil
        case .page(let object):
            return object.objectId
        case .list(let object):
            return object.objectId
        case .type(let object):
            return object.objectId
        }
    }
    
    var spaceId: String {
        switch self {
        case .favorites(_, let spaceId):
            return spaceId
        case .recentEdit(let spaceId):
            return spaceId
        case .recentOpen(let spaceId):
            return spaceId
        case .sets(let spaceId):
            return spaceId
        case .collections(let spaceId):
            return spaceId
        case .bin(let spaceId):
            return spaceId
        case .allContent(let spaceId):
            return spaceId
        case .page(let object):
            return object.spaceId
        case .list(let object):
            return object.spaceId
        case .date(let object):
            return object.spaceId
        case .type(let object):
            return object.spaceId
        }
    }
}

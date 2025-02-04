import Foundation
import Services

// MARK: - Init helpers

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
    func screenData(usecase: ObjectHeaderEmptyUsecase = .full) -> ScreenData {
        ScreenData(details: self, usecase: usecase)
    }
}

// MARK: Read fields helpers

extension EditorScreenData {
   
    var objectId: String? {
        switch self {
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin, .allContent, .date, .pages, .lists, .media, .bookmarks, .files:
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
        case .pages(let spaceId):
            return spaceId
        case .lists(let spaceId):
            return spaceId
        case .media(let spaceId):
            return spaceId
        case .bookmarks(let spaceId):
            return spaceId
        case .files(let spaceId):
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

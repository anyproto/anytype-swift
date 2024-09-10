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
        case .set:
            self = .set(EditorSetObject(
                details: details,
                activeViewId: activeViewId,
                mode: mode
            ))
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

extension EditorSetObject {
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
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin, .discussion, .allContent:
            return nil
        case .page(let object):
            return object.objectId
        case .set(let object):
            return object.objectId
        }
    }
    
    var spaceId: String? {
        switch self {
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin, .discussion, .allContent:
            return nil
        case .page(let object):
            return object.spaceId
        case .set(let object):
            return object.spaceId
        }
    }
}

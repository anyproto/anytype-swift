import Foundation
import Services

// MARK: - Init helpers

extension EditorScreenData {
    init(details: ObjectDetails, isOpenedForPreview: Bool = false) {
        switch details.editorViewType {
        case .page:
            self = .page(EditorPageObject(
                details: details,
                isOpenedForPreview: isOpenedForPreview
            ))
        case .set:
            self = .set(EditorSetObject(details: details))
        }
    }
}

extension EditorPageObject {
    init(
        details: ObjectDetails,
        isOpenedForPreview: Bool = false,
        usecase: ObjectHeaderEmptyData.ObjectHeaderEmptyUsecase = .editor
    ) {
        self.objectId = details.id
        self.spaceId = details.spaceId
        self.isOpenedForPreview = isOpenedForPreview
        self.usecase = usecase
    }
}

extension EditorSetObject {
    init(details: ObjectDetails) {
        self.objectId = details.id
        self.spaceId = details.spaceId
        self.inline = nil
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
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin:
            return nil
        case .page(let object):
            return object.objectId
        case .set(let object):
            return object.objectId
        }
    }
    
    var spaceId: String? {
        switch self {
        case .favorites, .recentEdit, .recentOpen, .sets, .collections, .bin:
            return nil
        case .page(let object):
            return object.spaceId
        case .set(let object):
            return object.spaceId
        }
    }
}

import Foundation
import Services

// MARK: - Init helpers

extension EditorScreenData {
    init(details: ObjectDetails, isOpenedForPreview: Bool = false) {
        switch details.editorViewType {
        case .page:
            self = .page(EditorPageObject(details: details, isOpenedForPreview: isOpenedForPreview))
        case .set:
            self = .set(EditorSetObject(details: details))
        }
    }
}

extension EditorPageObject {
    init(details: ObjectDetails, isOpenedForPreview: Bool = false) {
        self.objectId = details.id
        self.isSupportedForEdit = details.isSupportedForEdit
        self.isOpenedForPreview = isOpenedForPreview
    }
}

extension EditorSetObject {
    init(details: ObjectDetails) {
        self.objectId = details.id
        self.isSupportedForEdit = details.isSupportedForEdit
        self.inline = nil
    }
}

extension ObjectDetails {
    func editorScreenData(isOpenedForPreview: Bool = false) -> EditorScreenData {
        return EditorScreenData(details: self)
    }
}

// MARK: Read fields helpers

extension EditorScreenData {
    var isSupportedForEdit: Bool {
        switch self {
        case .favorites, .recent, .sets, .collections, .bin:
            return true
        case .page(let object):
            return object.isSupportedForEdit
        case .set(let object):
            return object.isSupportedForEdit
        }
    }
    
    var objectId: String {
        switch self {
        case .favorites, .recent, .sets, .collections, .bin:
            return ""
        case .page(let object):
            return object.objectId
        case .set(let object):
            return object.objectId
        }
    }
}

import Services
import AnytypeCore

enum ScreenType {
    case page
    case list
    case date
    case type
    case participant
    case mediaFile
}


enum ScreenData: Hashable, Identifiable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
    case preview(MediaFileScreenData)
    
    var id: Int { hashValue }
}

extension ScreenData {
    var objectId: String? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData.objectId
        case .alert(let alertScreenData):
            return alertScreenData.objectId
        case .preview:
            return nil
        }
    }
    
    var spaceId: String {
        switch self {
        case .editor(let editorScreenData):
            editorScreenData.spaceId
        case .alert(let alertScreenData):
            alertScreenData.spaceId
        case .preview(let mediaFileScreenData):
            mediaFileScreenData.spaceId
        }
    }
    
    var editorScreenData: EditorScreenData? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData
        case .alert, .preview:
            return nil
        }
    }
    
    var isSimpleSet: Bool {
        switch self {
        case .editor(let editorScreenData):
            return FeatureFlags.objectTypeWidgets ? editorScreenData.isSimpleSet : false
        case .alert, .preview:
            return false
        }
    }
}

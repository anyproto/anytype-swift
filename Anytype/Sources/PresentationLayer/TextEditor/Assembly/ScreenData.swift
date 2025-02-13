import Services

enum ScreenType {
    case page
    case list
    case date
    case type
    case participant
    case mediaFile
    case bookmark
}


enum ScreenData: Hashable, Identifiable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
    case preview(MediaFileScreenData)
    case bookmark(BookmarkScreenData)
    case settings(SettingsScreenData)
        
    var id: Int { hashValue }
}

extension ScreenData {
    var objectId: String? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData.objectId
        case .alert(let alertScreenData):
            return alertScreenData.objectId
        case .bookmark(let data):
            return data.editorScreenData.objectId
        case .preview, .settings:
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
        case .bookmark(let data):
            data.editorScreenData.spaceId
        case .settings(let data):
            data.spaceId
        }
    }
    
    var editorScreenData: EditorScreenData? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData
        case .alert, .preview, .bookmark, .settings:
            return nil
        }
    }
}

import Services
import AnytypeCore

enum ScreenType {
    case page
    case list
    case date
    case type
    case participant
    case mediaFile
    case bookmark
    case chat
}

enum ScreenData: Hashable, Identifiable, Sendable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
    case preview(MediaFileScreenData)
    case bookmark(BookmarkScreenData)
    case spaceInfo(SpaceInfoScreenData)
    case chat(ChatCoordinatorData)
    case widget(HomeWidgetData)
    // Use this if you don't know object type.
    // Navigation will request for the object type after the space is loaded.
    case anyObject(objectId: String, spaceId: String)
    
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
        case .anyObject(let objectId, _):
            return objectId
        case .preview, .spaceInfo, .chat, .widget:
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
        case .spaceInfo(let data):
            data.spaceId
        case .chat(let data):
            data.spaceId
        case .widget(let data):
            data.spaceId
        case .anyObject(_, let spaceId):
            spaceId
        }
    }
    
    var editorScreenData: EditorScreenData? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData
        default:
            return nil
        }
    }
    
    var isSimpleSet: Bool {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData.isSimpleSet
        default:
            return false
        }
    }
    
    var isAnyObject: Bool {
        switch self {
        case .anyObject:
            return true
        default:
            return false
        }
    }
}

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
    // Read SpaceChatCoordinatorView why chat and spaceChat are different
    case chat(ChatCoordinatorData)
    case spaceChat(SpaceChatCoordinatorData)
    case widget(HomeWidgetData)
    
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
        case .preview, .spaceInfo, .chat, .widget, .spaceChat:
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
        case .spaceChat(let data):
            data.spaceId
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
}

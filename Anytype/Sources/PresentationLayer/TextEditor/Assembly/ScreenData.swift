import Services

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
    case mediaFile(MediaFileScreenData)
    
    var id: Int { hashValue }
}

extension ScreenData {
    var objectId: String? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData.objectId
        case .alert(let alertScreenData):
            return alertScreenData.objectId
        case .mediaFile:
            return nil
        }
    }
    
    var spaceId: String {
        switch self {
        case .editor(let editorScreenData):
            editorScreenData.spaceId
        case .alert(let alertScreenData):
            alertScreenData.spaceId
        case .mediaFile(let mediaFileScreenData):
            mediaFileScreenData.spaceId
        }
    }
    
    var editorScreenData: EditorScreenData? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData
        case .alert, .mediaFile:
            return nil
        }
    }
}

struct MediaFileScreenData: Hashable {
    let item: PreviewRemoteItem
    
    var spaceId: String {
        item.fileDetails.spaceId
    }
}


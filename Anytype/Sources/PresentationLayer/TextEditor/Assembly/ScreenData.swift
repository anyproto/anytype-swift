import Services

enum ScreenType {
    case page
    case list
    case date
    case type
    case participant
}


enum ScreenData: Hashable, Codable, Identifiable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
    
    var id: Int { hashValue }
}

extension ScreenData {
    var objectId: String? {
        switch self {
        case .editor(let editorScreenData):
            editorScreenData.objectId
        case .alert(let alertScreenData):
            alertScreenData.objectId
        }
    }
    
    var spaceId: String {
        switch self {
        case .editor(let editorScreenData):
            editorScreenData.spaceId
        case .alert(let alertScreenData):
            alertScreenData.spaceId
        }
    }
    
    var editorScreenData: EditorScreenData? {
        switch self {
        case .editor(let editorScreenData):
            return editorScreenData
        case .alert:
            return nil
        }
    }
}


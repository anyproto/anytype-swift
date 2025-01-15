import Services

enum ScreenType {
    case page
    case list
    case date
    case type
    case participant
}


enum ScreenData: Hashable, Codable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
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
}


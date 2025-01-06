import Foundation

struct ChatLinkFromPanel {
    let spaceId: String
    let objectId: String
}

extension EditorScreenData {
    var chatLinkFromPanel: ChatLinkFromPanel? {
        switch self {
        case .page(let data):
            ChatLinkFromPanel(spaceId: data.spaceId, objectId: data.objectId)
        case .list(let data):
            ChatLinkFromPanel(spaceId: data.spaceId, objectId: data.objectId)
        default:
            nil
        }
    }
}

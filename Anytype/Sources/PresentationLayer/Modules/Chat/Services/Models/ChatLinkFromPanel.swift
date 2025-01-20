import Foundation

struct ChatLinkObject {
    let spaceId: String
    let objectId: String
}

extension EditorScreenData {
    var chatLink: ChatLinkObject? {
        switch self {
        case .page(let data):
            ChatLinkObject(spaceId: data.spaceId, objectId: data.objectId)
        case .list(let data):
            ChatLinkObject(spaceId: data.spaceId, objectId: data.objectId)
        default:
            nil
        }
    }
}

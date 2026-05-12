import SwiftUI

struct SpaceChatCoordinatorData: Codable {
    let spaceId: String
    let messageId: String?

    init(spaceId: String, messageId: String? = nil) {
        self.spaceId = spaceId
        self.messageId = messageId
    }
}

extension SpaceChatCoordinatorData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(spaceId)
    }

    static func == (lhs: SpaceChatCoordinatorData, rhs: SpaceChatCoordinatorData) -> Bool {
        lhs.spaceId == rhs.spaceId
    }
}

// For first sync, the SpaceView does not contain the chatId. Needs to open it first, then read the chatId.
struct SpaceChatCoordinatorView: View {
    
    let data: SpaceChatCoordinatorData
    
    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) { info in
            ChatCoordinatorView(data: ChatCoordinatorData(chatId: info.spaceChatId, spaceId: data.spaceId, messageId: data.messageId))
        }
    }
}

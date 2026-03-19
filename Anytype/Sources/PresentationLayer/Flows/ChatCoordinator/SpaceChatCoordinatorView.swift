import SwiftUI

struct SpaceChatCoordinatorData: Hashable, Codable {
    let spaceId: String
}

// For first sync, the SpaceView does not contain the chatId. Needs to open it first, then read the chatId.
struct SpaceChatCoordinatorView: View {
    
    let data: SpaceChatCoordinatorData
    
    var body: some View {
        SpaceLoadingContainerView(spaceId: data.spaceId, showBackground: true) { info in
            ChatCoordinatorView(data: ChatCoordinatorData(chatId: info.spaceChatId, spaceId: data.spaceId))
        }
    }
}

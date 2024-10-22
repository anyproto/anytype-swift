import SwiftUI
import AnytypeCore
import Services

struct HomeChatCoordinatorView: View {
    
    @StateObject private var model: HomeChatCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(spaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeChatCoordinatorViewModel(spaceInfo: spaceInfo))
    }
    
    var body: some View {
        ZStack {
            if let chatData = model.chatData {
                ChatCoordinatorView(data: chatData)
            }
        }
        .task {
            await model.startSubscription()
        }
    }
}

import SwiftUI
import AnytypeCore
import Services

struct HomeChatCoordinatorView: View {
    
    @StateObject private var model: HomeWidgetsCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init(spaceInfo: AccountInfo) {
        self._model = StateObject(wrappedValue: HomeWidgetsCoordinatorViewModel(spaceInfo: spaceInfo))
    }
    
    var body: some View {
        Text("Chat Coordinator")
    }
}

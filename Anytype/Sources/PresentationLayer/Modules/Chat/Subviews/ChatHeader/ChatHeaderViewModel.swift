import Foundation
import SwiftUI

@MainActor
final class ChatHeaderViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    @Published var title: String?
    @Published var icon: Icon?
    @Published var showWidgetsButton: Bool = false
    
    private let spaceId: String
    private let chatId: String
    private let onTapOpenWidgets: () -> Void
    
    init(spaceId: String, chatId: String, onTapOpenWidgets: @escaping () -> Void) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.onTapOpenWidgets = onTapOpenWidgets
    }
    
    func subscribe() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            title = spaceView.title
            icon = spaceView.objectIconImage
            showWidgetsButton = spaceView.chatId == chatId && spaceView.initialScreenIsChat && spaceView.chaToggleEnable
        }
    }
    
    func tapOpenWidgets() {
        onTapOpenWidgets()
    }
}

import Foundation
import SwiftUI
import Services
import Combine
import AnytypeCore

@MainActor
final class ChatHeaderViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    
    @Published var title: String?
    @Published var icon: Icon?
    @Published var showWidgetsButton: Bool = false
    @Published var showLoading = false
    
    private let spaceId: String
    private let chatId: String
    private let onTapOpenWidgets: () -> Void
    private let chatObject: any BaseDocumentProtocol
    
    init(spaceId: String, chatId: String, onTapOpenWidgets: @escaping () -> Void) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.onTapOpenWidgets = onTapOpenWidgets
        self.chatObject = openDocumentProvider.document(objectId: chatId, spaceId: spaceId)
    }
    
    func subscribeOnSpaceView() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            title = spaceView.title
            icon = spaceView.objectIconImage
            showWidgetsButton = spaceView.chatId == chatId && spaceView.initialScreenIsChat && spaceView.chatToggleEnable
        }
    }
    
    func subscribeOnChatStatus() async {
        guard FeatureFlags.chatLoadingIndicator else { return }
        
        let stream = chatObject.detailsPublisher
            .map {
                switch $0.syncStatusValue {
                case .synced, .error, .UNRECOGNIZED, .none:
                    return false
                case .syncing, .queued:
                    return true
                }
            }
            .removeDuplicates()
            .values
        
        for await loading in stream {
            showLoading = loading
        }
    }
    
    func tapOpenWidgets() {
        onTapOpenWidgets()
    }
}

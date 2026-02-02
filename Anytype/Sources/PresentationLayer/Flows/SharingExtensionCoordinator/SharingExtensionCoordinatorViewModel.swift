import SwiftUI
import SharedContentManager

@MainActor
@Observable
final class SharingExtensionCoordinatorViewModel: SharingExtensionModuleOutput, SharingExtensionShareToModuleOutput {

    @ObservationIgnored
    @Injected(\.sharedContentManager)
    private var contentManager: any SharedContentManagerProtocol

    var showShareTo: SharingExtensionShareToData?
    var suggestedSpaceId: String?
    var dismiss = false
    
    // MARK: - SharingExtensionModuleOutput
    
    func onSelectDataSpace(spaceId: String) {
        showShareTo = SharingExtensionShareToData(spaceId: spaceId)
    }
    
    // MARK: - SharingExtensionShareToModuleOutput
    
    func shareToFinished() {
        dismiss.toggle()
    }

    // MARK: - Suggestion Handling

    func checkForSuggestedConversation() async {
        guard let content = try? await contentManager.getSharedContent(),
              let conversationId = content.suggestedConversationId,
              let parsed = ConversationIdentifier.decode(from: conversationId) else {
            return
        }

        if let chatId = parsed.chatId {
            showShareTo = SharingExtensionShareToData(
                spaceId: parsed.spaceId,
                suggestedChatId: chatId
            )
        } else {
            suggestedSpaceId = parsed.spaceId
        }
    }
}

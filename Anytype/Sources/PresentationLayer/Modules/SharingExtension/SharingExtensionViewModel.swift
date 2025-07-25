import SwiftUI

@MainActor
final class SharingExtensionViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    @Published var spacesWithChat: [SpaceView] = []
    
    func onAppear() async {
        
    }
    
    // MARK: - Private
    
    private func startSpacesSub() async {
        for await spaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            spacesWithChat = spaces.filter { $0.canEdit && !$0.spaceView.chatId.isEmpty }.map { $0.spaceView }
        }
    }
}

import SwiftUI

@MainActor
final class SharingExtensionViewModel: ObservableObject {
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    
    @Published var spaces: [SpaceView] = []
    @Published var selectedSpace: SpaceView?
    
    func onAppear() async {
        await startSpacesSub()
    }
    
    func onTapSpace(_ space: SpaceView) {
        selectedSpace = space
    }
    
    // MARK: - Private
    
    private func startSpacesSub() async {
        for await participantSpaces in participantSpacesStorage.activeOrLoadingParticipantSpacesPublisher.values {
            spaces = participantSpaces.filter { $0.canEdit }.map { $0.spaceView }
        }
    }
}

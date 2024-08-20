import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject {
    private let onTap: () -> ()
    @Published var spaces = [ParticipantSpaceViewData]()
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: any ActiveWorkpaceStorageProtocol
    
    
    private var subscriptions = [AnyCancellable]()
    
    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
        
        Task { startSubscriptions() }
    }
    
    func onSpaceTap(spaceId: String) {
        Task {
            // TODO: Show spinner ???
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        }
    }
    
    // MARK: - Private
    private func startSubscriptions() {
        participantSpacesStorage.activeParticipantSpacesPublisher
            .receiveOnMain()
            .sink { [weak self] spaces in
                self?.spaces = spaces
            }
            .store(in: &subscriptions)
    }
    
}

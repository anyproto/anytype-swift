import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject, SpaceCreateModuleOutput {
    @Published var spaces = [ParticipantSpaceViewData]()
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: any ActiveWorkpaceStorageProtocol
    
    private let showActiveSpace: () -> ()
    private var subscriptions = [AnyCancellable]()
    
    init(showActiveSpace: @escaping () -> Void) {
        self.showActiveSpace = showActiveSpace
        
        Task { startSubscriptions() }
    }
    
    func onSpaceTap(spaceId: String) {
        Task {
            // TODO: Show spinner ???
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
            UISelectionFeedbackGenerator().selectionChanged()
            showActiveSpace()
        }
    }
    
    func spaceCreateWillDismiss() {
        showSpaceCreate = false
        showActiveSpace()
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

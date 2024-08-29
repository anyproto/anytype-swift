import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject, SpaceCreateModuleOutput {
    @Published var spaces: [ParticipantSpaceViewData]?
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    
    let sceneId: String
    
    var showPlusInNavbar: Bool {
        guard let spaces else { return false }
        return spaces.count > 6
    }
    
    @Injected(\.userDefaultsStorage)
    var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    
    private var subscriptions = [AnyCancellable]()
    
    
    init(sceneId: String) {
        self.sceneId = sceneId
        Task { startSubscriptions() }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenVault()
    }
    
    func onSpaceTap(spaceId: String) {
        Task {
            try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func spaceCreateWillDismiss() {
        showSpaceCreate = false

    }
    
    // MARK: - Private
    private func startSubscriptions() {
        participantSpacesStorage.activeParticipantSpacesPublisher
            .receiveOnMain()
            .sink { [weak self] spaces in
                guard let self else { return }
                
                self.spaces = spaces
            }
            .store(in: &subscriptions)
    }    
}

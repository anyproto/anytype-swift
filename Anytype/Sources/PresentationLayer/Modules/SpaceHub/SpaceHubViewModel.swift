import Services
import SwiftUI
import Combine


@MainActor
final class SpaceHubViewModel: ObservableObject, SpaceCreateModuleOutput {
    @Published var spaces: [ParticipantSpaceViewData]?
    
    @Published var showSpaceCreate = false
    @Published var showSettings = false
    
    var showPlusInNavbar: Bool {
        guard let spaces else { return false }
        return spaces.count > 6
    }
    
    @Injected(\.userDefaultsStorage)
    var userDefaults: any UserDefaultsStorageProtocol
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    // TODO: create new state manager for hub
    @Injected(\.homeActiveSpaceManager)
    private var homeActiveSpaceManager: any HomeActiveSpaceManagerProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    
    let homeSceneId = UUID().uuidString
    
    private let showActiveSpace: () -> ()
    private var subscriptions = [AnyCancellable]()
    
    init(showActiveSpace: @escaping () -> Void) {
        self.showActiveSpace = showActiveSpace
        
        Task {
            await spaceSetupManager.registryHome(homeSceneId: homeSceneId, manager: homeActiveSpaceManager)
        }
        
        Task { startSubscriptions() }
    }
    
    func onSpaceTap(spaceId: String) {
        Task {
            // TODO: Show spinner ???
            try await homeActiveSpaceManager.setActiveSpace(spaceId: spaceId)
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
                guard let self else { return }
                
                let initialIteration = self.spaces.isNil
                self.spaces = spaces
                
                if initialIteration { openScreenFromLastSessionIfNeeded() }
            }
            .store(in: &subscriptions)
    }
    
    private func openScreenFromLastSessionIfNeeded() {
        guard let spaces else { return }
        
        if spaces.count == 1 { showActiveSpace() }
    }
    
}

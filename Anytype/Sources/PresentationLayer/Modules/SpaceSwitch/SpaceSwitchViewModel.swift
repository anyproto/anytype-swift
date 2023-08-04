import Foundation
import Combine
import Services

@MainActor
final class SpaceSwitchViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    
    // MARK: - State
    
    private let profileSubId = "Profile-\(UUID().uuidString)"
    private var workspaces: [ObjectDetails]?
    private var activeWorkspaceInfo: AccountInfo?
    private var subscriptions = [AnyCancellable]()
    
    @Published var rows = [SpaceRowModel]()
    @Published var dismiss: Bool = false
    @Published var profileName: String = ""
    @Published var spaceCreateLoading: Bool = false
    
    init(
        workspacesStorage: WorkspacesStorageProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        workspaceService: WorkspaceServiceProtocol
    ) {
        self.workspacesStorage = workspacesStorage
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.workspaceService = workspaceService
        startProfileSubscriotions()
        startSpacesSubscriotions()
    }
    
    func onTapAddSpace() {
        Task {
            // Stop and start for fix big delay between receive workspace list and apply active space.
            // This delay occurs because middle send a lot of events for create workspace action.
            // It only fixes the not nice view update.
            spaceCreateLoading = true
            stopSpacesSubscriotions()
            defer {
                spaceCreateLoading = false
                startSpacesSubscriotions()
            }
            let spaceId = try await workspaceService.createWorkspace(name: "Workspace \(workspacesStorage.workspaces.count + 1)")
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
        
        }
    }
    
    // MARK: - Private
    
    private func startProfileSubscriotions() {
        subscriptionService.startSubscription(
            subIdPrefix: profileSubId,
            objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID
        ) { [weak self] details in
            self?.updateProfile(profile: details)
        }
    }
    
    private func startSpacesSubscriotions() {
        
        workspacesStorage.workspsacesPublisher
            .receiveOnMain()
            .sink { [weak self] workspaces in
                self?.workspaces = workspaces
                self?.updateViewModel()
            }
            .store(in: &subscriptions)
        
        activeWorkspaceStorage.workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] activeWorkspaceInfo in
                self?.activeWorkspaceInfo = activeWorkspaceInfo
                self?.updateViewModel()
            }
            .store(in: &subscriptions)
    }
    
    private func stopSpacesSubscriotions() {
        subscriptions.removeAll()
    }
    
    private func updateViewModel() {
        guard let activeWorkspaceInfo, let workspaces else {
            rows = []
            return
        }
        let activeSpaceId = activeWorkspaceInfo.accountSpaceId
        rows = workspaces.map { workspace -> SpaceRowModel in
            SpaceRowModel(
                id: workspace.id,
                title: workspace.title,
                isSelected: activeSpaceId == workspace.spaceId
            ) { [weak self] in
                self?.onTapWorkspace(workspace: workspace)
            }
        }
    }
    
    private func updateProfile(profile: ObjectDetails) {
        profileName = profile.title
    }
    
    private func onTapWorkspace(workspace: ObjectDetails) {
        Task {
            try await activeWorkspaceStorage.setActiveSpace(spaceId: workspace.spaceId)
        }
    }
}

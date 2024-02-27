import Foundation
import Combine
import Services
import UIKit

@MainActor
final class SpaceSwitchViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private weak var output: SpaceSwitchModuleOutput?
    
    // MARK: - State
    
    private let profileSubId = "Profile-\(UUID().uuidString)"
    private var spaces: [SpaceView]?
    private var activeWorkspaceInfo: AccountInfo?
    private var subscriptions = [AnyCancellable]()
    
    @Published var rows = [SpaceRowModel]()
    @Published var dismiss: Bool = false
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var scrollToRowId: String? = nil
    @Published var createSpaceAvailable: Bool = false
    @Published var spaceViewForDelete: SpaceView?
    
    init(
        workspacesStorage: WorkspacesStorageProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        accountManager: AccountManagerProtocol,
        workspaceService: WorkspaceServiceProtocol,
        output: SpaceSwitchModuleOutput?
    ) {
        self.workspacesStorage = workspacesStorage
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.accountManager = accountManager
        self.workspaceService = workspaceService
        self.output = output
        Task {
            await startProfileSubscriotions()
            startSpacesSubscriotions()
        }
    }
    
    func onAddSpaceTap() {
        output?.onCreateSpaceSelected()
    }
    
    func onProfileTap() {
        output?.onSettingsSelected()
    }
    
    func onDeleteConfirmationTap(space: SpaceView) {
        Task {
            AnytypeAnalytics.instance().logDeleteSpace(type: .private)
            try await workspaceService.deleteSpace(spaceId: space.targetSpaceId)
        }
    }
    
    // MARK: - Private
    
    private func startProfileSubscriotions() async {
        await subscriptionService.startSubscription(
            subId: profileSubId,
            objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID
        ) { [weak self] details in
            self?.updateProfile(profile: details)
        }
    }
    
    private func startSpacesSubscriotions() {
        
        workspacesStorage.workspsacesPublisher
            .receiveOnMain()
            .sink { [weak self] workspaces in
                self?.spaces = workspaces
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
        guard let activeWorkspaceInfo, let spaces else {
            rows = []
            return
        }
        let activeSpaceId = activeWorkspaceInfo.accountSpaceId
        
        rows = spaces.map { spaceView -> SpaceRowModel in
            SpaceRowModel(
                id: spaceView.id,
                title: spaceView.title,
                icon: spaceView.objectIconImage,
                isSelected: activeSpaceId == spaceView.targetSpaceId,
                shared: spaceView.spaceAccessType?.isShared ?? false,
                onTap: { [weak self] in
                    self?.onTapWorkspace(workspace: spaceView)
                },
                onDelete: accountManager.account.info.spaceViewId == spaceView.id ? nil : { [weak self] in
                    AnytypeAnalytics.instance().logClickDeleteSpace(route: .navigation)
                    self?.spaceViewForDelete = spaceView
                }
            )
        }
        
        if scrollToRowId.isNil, let selectedRow = rows.first(where: { $0.isSelected }) {
            scrollToRowId = selectedRow.id
        }
        
        createSpaceAvailable = workspacesStorage.canCreateNewSpace()
    }
    
    private func updateProfile(profile: ObjectDetails) {
        profileName = profile.title
        profileIcon = profile.objectIconImage
    }
    
    private func onTapWorkspace(workspace: SpaceView) {
        Task {
            stopSpacesSubscriotions()
            try await activeWorkspaceStorage.setActiveSpace(spaceId: workspace.targetSpaceId)
            UISelectionFeedbackGenerator().selectionChanged()
            dismiss.toggle()
        }
    }
}

import Foundation
import Combine
import Services
import UIKit

@MainActor
final class SpaceSwitchViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: WorkspacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: SingleObjectSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    private weak var output: SpaceSwitchModuleOutput?
    
    // MARK: - State
    
    private let profileSubId = "Profile-\(UUID().uuidString)"
    private var spaces: [ParticipantSpaceViewData]?
    private var activeWorkspaceInfo: AccountInfo?
    private var subscriptions = [AnyCancellable]()
    
    @Published var rows = [SpaceRowModel]()
    @Published var dismiss: Bool = false
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var scrollToRowId: String? = nil
    @Published var createSpaceAvailable: Bool = false
    @Published var spaceViewForDelete: SpaceView?
    @Published var spaceViewForLeave: SpaceView?
    @Published var spaceViewStopSharing: SpaceView?
    
    init(output: SpaceSwitchModuleOutput?) {
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
        
        participantSpacesStorage.activeParticipantSpacesPublisher
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
        
        rows = spaces.map { participantSpaceView -> SpaceRowModel in
            let spaceView = participantSpaceView.spaceView
            return SpaceRowModel(
                id: spaceView.id,
                title: spaceView.title,
                icon: spaceView.objectIconImage,
                isSelected: activeSpaceId == spaceView.targetSpaceId,
                shared: spaceView.isShared,
                onTap: { [weak self] in
                    self?.onTapWorkspace(workspace: spaceView)
                },
                onDelete: participantSpaceView.canBeDelete ? { [weak self] in
                    AnytypeAnalytics.instance().logClickDeleteSpace(route: .navigation)
                    self?.spaceViewForDelete = spaceView
                } : nil,
                onLeave: participantSpaceView.canLeave ? { [weak self] in
                    self?.spaceViewForLeave = spaceView
                } : nil,
                onStopShare: participantSpaceView.canStopSharing ? { [weak self] in
                    self?.spaceViewStopSharing = spaceView
                } : nil
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

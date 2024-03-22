import Foundation
import Combine
import Services
import UIKit

@MainActor
final class SpaceSettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let objectActionsService: ObjectActionsServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let participantSpacesStorage: ParticipantSpacesStorageProtocol
    private let dateFormatter = DateFormatter.relationDateFormatter
    private weak var output: SpaceSettingsModuleOutput?
    
    // MARK: - State
    
    let workspaceInfo: AccountInfo
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded = false
    private var participantSpaceView: ParticipantSpaceView?
    
    @Published var spaceName = ""
    @Published var spaceAccessType = ""
    @Published var spaceIcon: Icon?
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    @Published var showSpaceDeleteAlert = false
    @Published var showSpaceLeaveAlert = false
    @Published var dismiss = false
    @Published var allowDelete = false
    @Published var allowShare = false
    @Published var allowLeave = false
    @Published var allowSpaceMembers = false
    @Published var allowEditSpace = false
    @Published var allowRemoteStorage = false
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        workspaceService: WorkspaceServiceProtocol,
        accountManager: AccountManagerProtocol,
        participantSpacesStorage: ParticipantSpacesStorageProtocol,
        output: SpaceSettingsModuleOutput?
    ) {
        self.objectActionsService = objectActionsService
        self.relationDetailsStorage = relationDetailsStorage
        self.workspaceService = workspaceService
        self.accountManager = accountManager
        self.participantSpacesStorage = participantSpacesStorage
        self.output = output
        self.workspaceInfo = activeWorkspaceStorage.workspaceInfo
        Task {
            try await setupData()
        }
    }
    
    func onChangeIconTap() {
        output?.onChangeIconSelected(objectId: workspaceInfo.spaceViewId)
    }
    
    func onStorageTap() {
        output?.onRemoteStorageSelected()
    }
    
    func onPersonalizationTap() {
        output?.onPersonalizationSelected()
    }
    
    func onDeleteTap() {
        AnytypeAnalytics.instance().logClickDeleteSpace(route: .settings)
        showSpaceDeleteAlert.toggle()
    }
    
    func onShareTap() {
        output?.onSpaceShareSelected()
    }
    
    func onDeleteConfirmationTap() {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        Task {
            AnytypeAnalytics.instance().logDeleteSpace(type: .private)
            try await workspaceService.deleteSpace(spaceId: spaceView.targetSpaceId)
            dismiss.toggle()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceIndex()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    func onMembersTap() {
        output?.onSpaceMembersSelected()
    }
    
    // MARK: - Private
    
    private func setupData() async throws {
        participantSpacesStorage
            .activeParticipantSpacesPublisher
            .receiveOnMain()
            .sink { [weak self] participantSpaceViews in
                self?.participantSpaceView = participantSpaceViews.first { $0.spaceView.targetSpaceId == self?.workspaceInfo.accountSpaceId }
                self?.updateViewState()
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewState() {
        guard let participantSpaceView else { return }
        
        let spaceView = participantSpaceView.spaceView
        let participant = participantSpaceView.participant
        
        spaceIcon = spaceView.objectIconImage
        spaceAccessType = spaceView.spaceAccessType?.name ?? ""
        allowDelete = spaceView.canBeDelete
        allowLeave = participantSpaceView.canLeave
        allowShare = participantSpaceView.canBeShared
        allowSpaceMembers = !participantSpaceView.isOwner
        allowEditSpace = participantSpaceView.canEdit
        allowRemoteStorage = participantSpaceView.isOwner
        buildInfoBlock(details: spaceView)
        
        if !dataLoaded {
            spaceName = spaceView.name
            dataLoaded = true
            $spaceName
                .delay(for: 0.3, scheduler: DispatchQueue.main)
                .sink { [weak self] name in
                    self?.updateSpaceName(name: name)
                }
                .store(in: &subscriptions)
        }
    }
    
    private func buildInfoBlock(details: SpaceView) {
        
        info.removeAll()
        
        if let spaceRelationDetails = try? relationDetailsStorage.relationsDetails(for: .spaceId, spaceId: workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: spaceRelationDetails.name, subtitle: details.targetSpaceId, onTap: { [weak self] in
                    UIPasteboard.general.string = details.targetSpaceId
                    self?.snackBarData = .init(text: Loc.copiedToClipboard(spaceRelationDetails.name), showSnackBar: true)
                })
            )
        }
        
        if let creatorDetails = try? relationDetailsStorage.relationsDetails(for: .creator, spaceId: workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: creatorDetails.name, subtitle: accountManager.account.id, onTap: { [weak self] in
                    guard let self else { return }
                    UIPasteboard.general.string = accountManager.account.id
                    snackBarData = .init(text: Loc.copiedToClipboard(creatorDetails.name), showSnackBar: true)
                })
            )
        }
        
        info.append(
            SettingsInfoModel(title: Loc.SpaceSettings.networkId, subtitle: workspaceInfo.networkId, onTap: { [weak self] in
                guard let self else { return }
                UIPasteboard.general.string = workspaceInfo.networkId
                snackBarData = .init(text: Loc.copiedToClipboard(Loc.SpaceSettings.networkId), showSnackBar: true)
            })
        )
        
        if let createdDateDetails = try? relationDetailsStorage.relationsDetails(for: .createdDate, spaceId: workspaceInfo.accountSpaceId),
           let date = details.createdDate.map({ dateFormatter.string(from: $0) }) {
            info.append(
                SettingsInfoModel(title: createdDateDetails.name, subtitle: date)
            )
        }
    }
    
    private func updateSpaceName(name: String) {
        Task {
            try await workspaceService.workspaceSetDetails(
                spaceId: workspaceInfo.accountSpaceId,
                details: [.name(name)]
            )
        }
    }
}

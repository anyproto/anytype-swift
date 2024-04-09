import Foundation
import Combine
import Services
import UIKit
import AnytypeCore


@MainActor
final class SpaceSettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: RelationDetailsStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    
    private let dateFormatter = DateFormatter.relationDateFormatter
    private weak var output: SpaceSettingsModuleOutput?
    
    // MARK: - State
    
    lazy var workspaceInfo: AccountInfo = activeWorkspaceStorage.workspaceInfo
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded = false
    private var participantSpaceView: ParticipantSpaceView?
    private var joiningCount: Int = 0
    
    @Published var spaceName = ""
    @Published var spaceAccessType = ""
    @Published var spaceIcon: Icon?
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    @Published var showSpaceDeleteAlert = false
    @Published var showSpaceLeaveAlert = false
    @Published var dismiss = false
    @Published var allowDelete = false
    @Published var allowLeave = false
    @Published var allowEditSpace = false
    @Published var allowRemoteStorage = false
    @Published var shareSection: SpaceSettingsShareSection = .personal
    
    init(output: SpaceSettingsModuleOutput?) {
        self.output = output
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
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceIndex()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    func onMembersTap() {
        output?.onSpaceMembersSelected()
    }
    
    func startJoiningTask() async {
        for await participants in activeSpaceParticipantStorage.participantsPublisher.values {
            joiningCount = participants.filter { $0.status == .joining }.count
            updateViewState()
        }
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
        
        spaceIcon = spaceView.objectIconImage
        spaceAccessType = spaceView.spaceAccessType?.name ?? ""
        allowDelete = spaceView.canBeDelete
        allowLeave = participantSpaceView.canLeave
        allowEditSpace = participantSpaceView.canEdit
        allowRemoteStorage = participantSpaceView.isOwner
        buildInfoBlock(details: spaceView)
        
        if participantSpaceView.canBeShared {
            if participantSpaceView.spaceView.spaceAccessType == .shared {
                shareSection = .owner(joiningCount: joiningCount)
            } else {
                shareSection = .private(active: participantSpacesStorage.canShareSpace())
            }
        } else if !participantSpaceView.isOwner {
            shareSection = .member
        } else {
            shareSection = .personal
        }
        
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
            let owner = activeSpaceParticipantStorage.participants.first(where: { $0.isOwner })
            anytypeAssert(owner.isNotNil, "Could not find owner for space)", info: ["SpaceView": participantSpaceView.debugDescription])
            
            if let owner {
                info.append(
                    SettingsInfoModel(title: creatorDetails.name, subtitle: owner.globalName, onTap: { [weak self] in
                        guard let self else { return }
                        UIPasteboard.general.string = owner.globalName
                        snackBarData = .init(text: Loc.copiedToClipboard(creatorDetails.name), showSnackBar: true)
                    })
                )
            }
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

import Foundation
import Combine
import Services
import UIKit

@MainActor
final class SpaceSettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let dateFormatter = DateFormatter.relationDateFormatter
    private weak var output: SpaceSettingsModuleOutput?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded: Bool = false
    private let subSpaceId = "SpaceSettingsViewModel-Space-\(UUID())"
    private var spaceView: SpaceView?
    
    @Published var spaceName: String = ""
    @Published var spaceType: String = ""
    @Published var spaceIcon: Icon?
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    @Published var showSpaceDeleteAlert = false
    @Published var dismiss: Bool = false
    @Published var allowDelete: Bool = false
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        workspaceService: WorkspaceServiceProtocol,
        accountManager: AccountManagerProtocol,
        output: SpaceSettingsModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.objectActionsService = objectActionsService
        self.relationDetailsStorage = relationDetailsStorage
        self.workspaceService = workspaceService
        self.accountManager = accountManager
        self.output = output
        Task {
            await setupSubscription()
        }
    }
    
    func onChangeIconTap() {
        output?.onChangeIconSelected(objectId: activeWorkspaceStorage.workspaceInfo.spaceViewId)
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
        guard let spaceView else { return }
        Task {
            AnytypeAnalytics.instance().logDeleteSpace(type: .private)
            try await workspaceService.deleteSpace(spaceId: spaceView.targetSpaceId)
            dismiss.toggle()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceIndex()
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        await subscriptionService.startSubscription(
            subId: subSpaceId,
            objectId: activeWorkspaceStorage.workspaceInfo.spaceViewId,
            additionalKeys: SpaceView.subscriptionKeys
        ) { [weak self] details in
            self?.handleSpaceDetails(details: SpaceView(details: details))
        }
    }
    
    private func handleSpaceDetails(details: SpaceView) {
        spaceView = details
        spaceIcon = details.objectIconImage
        spaceType = details.spaceAccessType?.name ?? ""
        allowDelete = details.spaceAccessType == .personal || details.spaceAccessType == .private
        buildInfoBlock(details: details)
        
        if !dataLoaded {
            spaceName = details.name
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
        
        if let spaceRelationDetails = try? relationDetailsStorage.relationsDetails(for: .spaceId, spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: spaceRelationDetails.name, subtitle: details.targetSpaceId, onTap: { [weak self] in
                    UIPasteboard.general.string = details.targetSpaceId
                    self?.snackBarData = .init(text: Loc.copiedToClipboard(spaceRelationDetails.name), showSnackBar: true)
                })
            )
        }
        
        if let creatorDetails = try? relationDetailsStorage.relationsDetails(for: .creator, spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: creatorDetails.name, subtitle: accountManager.account.id, onTap: { [weak self] in
                    guard let self else { return }
                    UIPasteboard.general.string = accountManager.account.id
                    snackBarData = .init(text: Loc.copiedToClipboard(creatorDetails.name), showSnackBar: true)
                })
            )
        }
        
        info.append(
            SettingsInfoModel(title: Loc.SpaceSettings.networkId, subtitle: activeWorkspaceStorage.workspaceInfo.networkId, onTap: { [weak self] in
                guard let self else { return }
                UIPasteboard.general.string = activeWorkspaceStorage.workspaceInfo.networkId
                snackBarData = .init(text: Loc.copiedToClipboard(Loc.SpaceSettings.networkId), showSnackBar: true)
            })
        )
        
        if let createdDateDetails = try? relationDetailsStorage.relationsDetails(for: .createdDate, spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId),
           let date = details.createdDate.map({ dateFormatter.string(from: $0) }) {
            info.append(
                SettingsInfoModel(title: createdDateDetails.name, subtitle: date)
            )
        }
    }
    
    private func updateSpaceName(name: String) {
        Task {
            try await workspaceService.workspaceSetDetails(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                details: [.name(name)]
            )
        }
    }
}

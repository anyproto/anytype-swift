import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine
import Services

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: SettingsModuleOutput?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var spaceDataLoaded: Bool = false
    private var profileDataLoaded: Bool = false
    private let subSpaceId = "SettingsViewModel-Space-\(UUID().uuidString)"
    private let subAccountId = "SettingsAccount-\(UUID().uuidString)"
    
    @Published var spaceName: String = ""
    @Published var spaceIcon: Icon?
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: SettingsModuleOutput?
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.subscriptionService = subscriptionService
        self.objectActionsService = objectActionsService
        self.output = output
        Task {
            await setupSubscription()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.settingsShow)
    }
    
    func onAccountDataTap() {
        output?.onAccountDataSelected()
    }
    
    func onDebugMenuTap() {
        output?.onDebugMenuSelected()
    }
    
    func onPersonalizationTap() {
        output?.onPersonalizationSelected()
    }
    
    func onAppearanceTap() {
        output?.onAppearanceSelected()
    }
    
    func onFileStorageTap() {
        output?.onFileStorageSelected()
    }
    
    func onAboutTap() {
        output?.onAboutSelected()
    }
    
    func onChangeIconTap() {
        if FeatureFlags.multiSpaceSettings {
            output?.onChangeIconSelected(objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID)
        } else {
            output?.onChangeIconSelected(objectId: activeWorkspaceStorage.workspaceInfo.workspaceObjectId)
        }
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        await subscriptionService.startSubscription(
            subId: subSpaceId,
            objectId: activeWorkspaceStorage.workspaceInfo.workspaceObjectId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
        
        await subscriptionService.startSubscription(
            subId: subAccountId,
            objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID
        ) { [weak self] details in
            self?.handleProfileDetails(details: details)
        }
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceIcon = details.objectIconImage
        
        if !spaceDataLoaded {
            spaceName = details.name
            spaceDataLoaded = true
            $spaceName
                .delay(for: 0.3, scheduler: DispatchQueue.main)
                .sink { [weak self] name in
                    self?.updateSpaceName(name: name)
                }
                .store(in: &subscriptions)
        }
    }
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileIcon = details.objectIconImage
        
        if !profileDataLoaded {
            profileName = details.name
            profileDataLoaded = true
            $profileName
                .delay(for: 0.3, scheduler: DispatchQueue.main)
                .sink { [weak self] name in
                    self?.updateProfileName(name: name)
                }
                .store(in: &subscriptions)
        }
    }
    
    private func updateSpaceName(name: String) {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: activeWorkspaceStorage.workspaceInfo.workspaceObjectId,
                details: [.name(name)]
            )
        }
    }
    
    private func updateProfileName(name: String) {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: activeWorkspaceStorage.workspaceInfo.profileObjectID,
                details: [.name(name)]
            )
        }
    }
}

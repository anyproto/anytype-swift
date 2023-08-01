import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine
import Services

@MainActor
final class SettingsViewModel: ObservableObject {
    
    private enum Constants {
        static let subSpaceId = "SettingsSpace"
        static let subAccountId = "SettingsAccount"
    }
    
    // MARK: - DI
    
    private let accountManager: AccountManagerProtocol
    private let subscriptionService: SingleObjectSubscriptionServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: SettingsModuleOutput?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var dataLoaded: Bool = false
    
    @Published var spaceName: String = ""
    @Published var spaceIcon: Icon?
    @Published var profileIcon: Icon = .asset(.SettingsOld.accountAndData)
    
    init(
        accountManager: AccountManagerProtocol,
        subscriptionService: SingleObjectSubscriptionServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: SettingsModuleOutput?
    ) {
        self.accountManager = accountManager
        self.subscriptionService = subscriptionService
        self.objectActionsService = objectActionsService
        self.output = output
        
        setupSubscription()
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
        output?.onChangeIconSelected(objectId: accountManager.account.info.accountSpaceId)
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subSpaceId,
            objectId: accountManager.account.info.accountSpaceId
        ) { [weak self] details in
            self?.handleSpaceDetails(details: details)
        }
        
        subscriptionService.startSubscription(
            subIdPrefix: Constants.subAccountId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.handleProfileDetails(details: details)
        }
    }
    
    private func handleSpaceDetails(details: ObjectDetails) {
        spaceIcon = details.objectIconImage
        
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
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileIcon = details.objectIconImage ?? .asset(.SettingsOld.accountAndData)
    }
    
    private func updateSpaceName(name: String) {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: accountManager.account.info.accountSpaceId,
                details: [.name(name)]
            )
        }
    }
}

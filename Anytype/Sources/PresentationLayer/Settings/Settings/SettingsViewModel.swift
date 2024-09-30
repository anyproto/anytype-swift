import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine
import Services

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - DI
    private var accountManager: any AccountManagerProtocol
    
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    
    private weak var output: (any SettingsModuleOutput)?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var profileDataLoaded: Bool = false
    private let subAccountId = "SettingsAccount-\(UUID().uuidString)"
    
    private let isInProdOrStagingNetwork: Bool
    var canShowMemberhip: Bool { isInProdOrStagingNetwork }
    
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var membership: MembershipStatus = .empty
    @Published var exportStackGoroutines = false
    
    init(output: some SettingsModuleOutput) {
        self.output = output
        
        accountManager = Container.shared.accountManager.resolve()
        isInProdOrStagingNetwork = accountManager.account.isInProdOrStagingNetwork
        
        Task {
            await setupSubscription()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsAccount()
    }
    
    func onAccountDataTap() {
        output?.onAccountDataSelected()
    }
    
    func onDebugMenuTap() {
        output?.onDebugMenuSelected()
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
        output?.onChangeIconSelected(objectId: accountManager.account.info.profileObjectID)
    }
    
    func onSpacesTap() {
        output?.onSpacesSelected()
    }
    
    func onMembershipTap() {
        output?.onMembershipSelected()
    }
    
    func onExportStackGoroutinesTap() {
        exportStackGoroutines = true
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        membershipStatusStorage.statusPublisher.assign(to: &$membership)
        
        await subscriptionService.startSubscription(
            subId: subAccountId,
            spaceId: accountManager.account.info.techSpaceId,
            objectId: accountManager.account.info.profileObjectID
        ) { [weak self] details in
            self?.handleProfileDetails(details: details)
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
    
    private func updateProfileName(name: String) {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: accountManager.account.info.profileObjectID,
                details: [.name(name)]
            )
        }
    }
}

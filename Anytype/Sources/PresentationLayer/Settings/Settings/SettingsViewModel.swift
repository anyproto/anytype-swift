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
    @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    
    private weak var output: (any SettingsModuleOutput)?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var profileDataLoaded: Bool = false
    private let subAccountId = "SettingsAccount-\(UUID().uuidString)"
    
    private let allowMembership: Bool
    var canShowMemberhip: Bool { allowMembership }
    
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var membership: MembershipStatus = .empty
    @Published var showDebugMenu = false
    @Published var notificationsDenied = false
    
    init(output: some SettingsModuleOutput) {
        self.output = output
        
        accountManager = Container.shared.accountManager.resolve()
        allowMembership = accountManager.account.allowMembership
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
    
    func onNotificationsTap() {
        output?.onNotificationsSelected()
    }
    
    func onFileStorageTap() {
        output?.onFileStorageSelected()
    }
    
    func onAboutTap() {
        output?.onAboutSelected()
    }
    
    func onChangeIconTap() {
        output?.onChangeIconSelected(objectId: accountManager.account.info.profileObjectID, spaceId: accountManager.account.info.techSpaceId)
    }
    
    func onSpacesTap() {
        output?.onSpacesSelected()
    }
    
    func onMembershipTap() {
        output?.onMembershipSelected()
    }
    
    func startSubscriptions() async {
        async let membershipSub: () = membershipSubscriotion()
        async let profileSub: () = profileSubscription()
        async let pushNotificationsSystemSettingsSub: () = pushNotificationsSystemSettingsSubscription()
        _ = await (membershipSub, profileSub, pushNotificationsSystemSettingsSub)
    }
    
    // MARK: - Private
    
    private func membershipSubscriotion() async {
        for await newMembership in membershipStatusStorage.statusPublisher.values {
            membership = newMembership
        }
    }
    
    private func profileSubscription() async {
        for await profile in profileStorage.profilePublisher.values {
            handleProfileDetails(profile: profile)
        }
    }
    
    private func pushNotificationsSystemSettingsSubscription() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            notificationsDenied = status.isDenied
        }
    }
    
    private func handleProfileDetails(profile: Profile) {
        profileIcon = profile.icon
        
        if !profileDataLoaded {
            profileName = profile.name
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

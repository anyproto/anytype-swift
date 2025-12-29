import SwiftUI
import ProtobufMessages
import AnytypeCore
import Services

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - DI

    @ObservationIgnored
    private var accountManager: any AccountManagerProtocol

    @ObservationIgnored @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @ObservationIgnored @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @ObservationIgnored @Injected(\.profileStorage)
    private var profileStorage: any ProfileStorageProtocol
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol

    @ObservationIgnored
    private weak var output: (any SettingsModuleOutput)?
    
    // MARK: - State

    @ObservationIgnored
    private var profileNameDebounceTask: Task<Void, Never>?
    @ObservationIgnored
    private var profileDataLoaded: Bool = false
    @ObservationIgnored
    private let subAccountId = "SettingsAccount-\(UUID().uuidString)"

    let canShowMemberhip: Bool
    let canDeleteVault: Bool

    var profileName: String = ""
    var profileIcon: Icon?
    var membership: MembershipStatus = .empty
    var notificationsDenied = false

    var anyNameBadgeState: AnyNameBadgeState {
        if membership.anyName.handle.isNotEmpty {
            return .memberName(membership.anyName.formatted)
        } else {
            return .anytypeId(accountManager.account.id)
        }
    }

    init(output: some SettingsModuleOutput) {
        self.output = output
        
        accountManager = Container.shared.accountManager.resolve()
        canShowMemberhip = accountManager.account.allowMembership
        
        let configurationStorage = Container.shared.serverConfigurationStorage.resolve()
        canDeleteVault = !configurationStorage.currentConfiguration().isLocalOnly
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
    
    func onMySitesTap() {
        output?.onMySitesSelected()
    }
    
    func onExterimentapTap() {
        output?.onExperimentalSelected()
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

    func onAnyIdBadgeTap() {
        output?.onAnyIdBadgeTapped()
    }

    func onQRCodeTap() {
        output?.onProfileQRCodeSelected()
    }
    
    func onLogoutTap() {
        output?.onLogoutSelected()
    }
    
    func onDeleteAccountTap() {
        output?.onDeleteAccountSelected()
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
        }
    }

    func onProfileNameChange() {
        guard profileDataLoaded else { return }

        profileNameDebounceTask?.cancel()
        profileNameDebounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled, let self else { return }
            await updateProfileName(name: profileName)
        }
    }

    private func updateProfileName(name: String) async {
        try? await objectActionsService.updateBundledDetails(
            contextID: accountManager.account.info.profileObjectID,
            details: [.name(name)]
        )
    }
}

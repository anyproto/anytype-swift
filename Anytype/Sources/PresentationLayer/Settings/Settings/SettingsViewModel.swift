import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine
import Services

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: SingleObjectSubscriptionServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    private weak var output: SettingsModuleOutput?
    
    // MARK: - State
    
    private var subscriptions: [AnyCancellable] = []
    private var profileDataLoaded: Bool = false
    private let subAccountId = "SettingsAccount-\(UUID().uuidString)"
    
    @Published var profileName: String = ""
    @Published var profileIcon: Icon?
    @Published var membership: MembershipStatus = .empty
    
    init(output: SettingsModuleOutput) {
        self.output = output
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
        output?.onChangeIconSelected(objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID)
    }
    
    func onSpacesTap() {
        output?.onSpacesSelected()
    }
    
    func onMembershipTap() {
        output?.onMembershipSelected()
    }
    
    // MARK: - Private
    
    private func setupSubscription() async {
        membershipStatusStorage.statusPublisher.assign(to: &$membership)
        
        await subscriptionService.startSubscription(
            subId: subAccountId,
            objectId: activeWorkspaceStorage.workspaceInfo.profileObjectID
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
                contextID: activeWorkspaceStorage.workspaceInfo.profileObjectID,
                details: [.name(name)]
            )
        }
    }
}

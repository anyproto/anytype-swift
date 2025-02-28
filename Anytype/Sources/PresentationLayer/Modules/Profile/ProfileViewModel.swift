import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var details: Participant?
    @Published var showSettings = false
    
    var isOwner: Bool {
        accountManager.account.info.profileObjectID == details?.identityProfileLink
    }
    
    private let info: ObjectInfo
    
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private let subId = "ProfileViewModel-\(UUID().uuidString)"
    
    init(info: ObjectInfo) {
        self.info = info
    }
    
    func setupSubscriptions() async {
        async let subscription: () = subscribe()
        
        (_) = await (subscription)
    }
    
    // MARK: - Private
    private func subscribe() async {
        
        await subscriptionService.startSubscription(
            subId: subId,
            spaceId: info.spaceId,
            objectId: info.objectId,
            additionalKeys: Participant.subscriptionKeys
        ) { [weak self] details in
            await self?.handleProfileDetails(details)
        }
    }
    
    private func handleProfileDetails(_ details: ObjectDetails) async {
        self.details = try? Participant(details: details)
    }
}

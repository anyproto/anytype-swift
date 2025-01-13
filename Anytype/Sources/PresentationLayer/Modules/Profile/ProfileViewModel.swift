import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var details: ObjectDetails?
    
    private let info: ObjectInfo
    
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    
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
            additionalKeys: [.identity]
        ) { [weak self] details in
            await self?.handleProfileDetails(details)
        }
    }
    
    private func handleProfileDetails(_ details: ObjectDetails) async {
        self.details = details
    }
}

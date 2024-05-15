import Services
import Foundation


@MainActor
final class MembershipOwnerInfoSheetViewModel: ObservableObject {
    
    @Published var membership: MembershipStatus = .empty
    @Published var showMangeButton = false
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipMetadataProvider)
    private var metadataProvider: MembershipMetadataProviderProtocol
    
    init() {
        let storage = Container.shared.membershipStatusStorage.resolve()
        storage.statusPublisher.receiveOnMain().assign(to: &$membership)
    }
    
    func updateState() {
        Task {
            let purchaseType = await metadataProvider.purchaseType(status: membership)
            switch purchaseType {
            case .purchasedInAppStoreWithCurrentAccount:
                showMangeButton = true
            case .purchasedInAppStoreWithOtherAccount, .purchasedElsewhere:
                showMangeButton = false
            }
        }
    }
    
    func getVerificationEmail(email: String) async throws {
        try await membershipService.getVerificationEmail(email: email)
    }
}

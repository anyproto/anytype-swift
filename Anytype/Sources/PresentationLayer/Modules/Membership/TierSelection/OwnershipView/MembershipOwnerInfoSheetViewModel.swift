import Services
import Foundation


@MainActor
final class MembershipOwnerInfoSheetViewModel: ObservableObject {
    
    @Published var membership: MembershipStatus = .empty
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: MembershipStatusStorageProtocol
    
    init() {
        membershipStatusStorage.status.receiveOnMain().assign(to: &$membership)
    }
    
    func getVerificationEmail(email: String) async throws {
        try await membershipService.getVerificationEmail(email: email)
    }
}

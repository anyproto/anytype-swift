import Services
import Foundation


@MainActor
final class MembershipOwnerInfoSheetViewModel: ObservableObject {
    
    @Published var membership: MembershipStatus = .empty
    
    @Published var purchaseType: MembershipPurchaseType?
    @Published var showManageSubscriptions = false
    @Published var showEmailVerification = false
    
    @Published var email: String = ""
    @Published var changeEmail = false
    @Published var toastData: ToastBarData?
    
    // remove after middleware start to send update membership event
    @Published private var justUpdatedEmail = false
    var alreadyHaveEmail: Bool {
        membership.email.isNotEmpty || justUpdatedEmail
    }
    
    
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.membershipMetadataProvider)
    private var metadataProvider: any MembershipMetadataProviderProtocol
    
    init() {
        let storage = Container.shared.membershipStatusStorage.resolve()
        storage.statusPublisher.receiveOnMain().assign(to: &$membership)
    }
    
    func updateState() {
        Task { self.purchaseType = await metadataProvider.purchaseType(status: membership) }
    }
    
    func getVerificationEmail(email: String) async throws {
        try await membershipService.getVerificationEmailSubscribeToNewsletter(email: email)
        self.email = email
        showEmailVerification = true
    }
    
    func onSuccessfullEmailVerification() {
        showEmailVerification = false
        changeEmail = false
        justUpdatedEmail = true
        toastData = ToastBarData(Loc.emailSuccessfullyValidated)
    }
}

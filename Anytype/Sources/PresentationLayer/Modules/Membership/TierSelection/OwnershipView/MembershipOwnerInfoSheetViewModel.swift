import Services
import Foundation


@MainActor
@Observable
final class MembershipOwnerInfoSheetViewModel {

    var membership: MembershipStatus = .empty

    var purchaseType: MembershipPurchaseType?
    var showManageSubscriptions = false
    var showEmailVerification = false

    var email: String = ""
    var changeEmail = false
    var toastData: ToastBarData?

    // remove after middleware start to send update membership event
    private var justUpdatedEmail = false
    var alreadyHaveEmail: Bool {
        membership.email.isNotEmpty || justUpdatedEmail
    }


    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @ObservationIgnored @Injected(\.membershipMetadataProvider)
    private var metadataProvider: any MembershipMetadataProviderProtocol
    @ObservationIgnored @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol

    init() { }

    func startMembershipSubscription() async {
        for await status in membershipStatusStorage.statusPublisher.values {
            membership = status
        }
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

import SwiftUI
import Services


@MainActor
@Observable
final class MembershipTierSelectionViewModel {

    var state: MembershipTierOwningState?

    @ObservationIgnored
    let userMembership: MembershipStatus
    @ObservationIgnored
    let tierToDisplay: MembershipTier

    @ObservationIgnored
    let onSuccessfulPurchase: (MembershipTier) -> ()

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @ObservationIgnored @Injected(\.membershipMetadataProvider)
    private var membershipMetadataProvider: any MembershipMetadataProviderProtocol

    init(
        userMembership: MembershipStatus,
        tierToDisplay: MembershipTier,
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
    ) {
        self.userMembership = userMembership
        self.tierToDisplay = tierToDisplay
        self.onSuccessfulPurchase = onSuccessfulPurchase
    }

    func onAppear() async {
        state = await membershipMetadataProvider.owningState(tier: tierToDisplay)
    }
}

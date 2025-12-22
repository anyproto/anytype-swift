import Services
import SwiftUI


@MainActor
@Observable
final class MembershipTierViewModel {

    var state: MembershipTierOwningState?
    var userMembership: MembershipStatus = .empty

    @ObservationIgnored
    let tierToDisplay: MembershipTier
    @ObservationIgnored
    let onTap: () -> ()

    @ObservationIgnored @Injected(\.membershipMetadataProvider)
    private var tierMetadataProvider: any MembershipMetadataProviderProtocol
    @ObservationIgnored @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol

    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        self.tierToDisplay = tierToDisplay
        self.onTap = onTap
    }

    func startMembershipSubscription() async {
        for await status in membershipStatusStorage.statusPublisher.values {
            userMembership = status
        }
    }

    func updateState() {
        Task {
            state = await tierMetadataProvider.owningState(tier: tierToDisplay)
        }
    }
}

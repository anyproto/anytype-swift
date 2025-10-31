import Services
import SwiftUI


@MainActor
final class MembershipTierViewModel: ObservableObject {
    
    @Published var state: MembershipTierOwningState?
    @Published var userMembership: MembershipStatus = .empty
    
    let tierToDisplay: MembershipTier
    let onTap: () -> ()
    
    @Injected(\.membershipMetadataProvider)
    private var tierMetadataProvider: any MembershipMetadataProviderProtocol
    private var statusTask: Task<Void, Never>?

    init(
        tierToDisplay: MembershipTier,
        onTap: @escaping () -> Void
    ) {
        self.tierToDisplay = tierToDisplay
        self.onTap = onTap
        
        let storage = Container.shared.membershipStatusStorage.resolve()
        statusTask = Task { [weak self] in
            guard let self else { return }
            for await status in storage.statusStream() {
                self.userMembership = status
            }
        }
    }
    
    deinit {
        statusTask?.cancel()
    }

    func updateState() {
        Task {
            state = await tierMetadataProvider.owningState(tier: tierToDisplay)
        }
    }
}

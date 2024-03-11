import Foundation
import Services
import Combine


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var userTier: MembershipTier?
    private var cancellable: AnyCancellable?
    
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        userTierPublisher: AnyPublisher<MembershipTier?, Never>,
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.onTierTap = onTierTap
        cancellable = userTierPublisher.assign(to: \.userTier, on: self)
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}

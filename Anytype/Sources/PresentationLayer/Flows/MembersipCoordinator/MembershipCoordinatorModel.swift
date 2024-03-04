import SwiftUI


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    let membershipAssembly: MembershipModuleAssemblyProtocol
    
    init(membershipAssembly: MembershipModuleAssemblyProtocol) {
        self.membershipAssembly = membershipAssembly
    }
    
    func initialModule() -> AnyView {
        membershipAssembly.make()
    }
}

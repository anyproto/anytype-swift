import SwiftUI


@MainActor
protocol MembershipModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class MembershipModuleAssembly: MembershipModuleAssemblyProtocol {
    
    nonisolated init() { }
    
    func make() -> AnyView {
        Text("TBD 🫵🐷").eraseToAnyView()
    }
}

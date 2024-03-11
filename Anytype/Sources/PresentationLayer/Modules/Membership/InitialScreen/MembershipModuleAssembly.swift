import SwiftUI
import Services


@MainActor
protocol MembershipModuleAssemblyProtocol: AnyObject {
    func make(onTierSelection: @escaping ((MembershipTier) -> ())) -> AnyView
}

final class MembershipModuleAssembly: MembershipModuleAssemblyProtocol {
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    nonisolated init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    func make(onTierSelection: @escaping ((MembershipTier) -> ())) -> AnyView {
        MembershipModuleView(
            model: MembershipModuleViewModel(
                membershipService: self.serviceLocator.membershipService(),
                urlOpener: self.uiHelpersDI.urlOpener(),
                onTierTap: onTierSelection
            )
        ).eraseToAnyView()
    }
}

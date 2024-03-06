import SwiftUI
import Services


@MainActor
protocol MembershipModuleAssemblyProtocol: AnyObject {
    func make(onTierSelection: @escaping ((MembershipTier) -> ())) -> AnyView
}

final class MembershipModuleAssembly: MembershipModuleAssemblyProtocol {
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    func make(onTierSelection: @escaping ((MembershipTier) -> ())) -> AnyView {
        MembershipModuleView(
            model: MembershipModuleViewModel(
                urlOpener: self.uiHelpersDI.urlOpener(),
                onTierTap: onTierSelection
            )
        ).eraseToAnyView()
    }
}

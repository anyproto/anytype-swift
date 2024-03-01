import SwiftUI


@MainActor
protocol MembershipModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class MembershipModuleAssembly: MembershipModuleAssemblyProtocol {
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    func make() -> AnyView {
        MembershipModuleView(
            model: MembershipModuleViewModel(
                urlOpener: self.uiHelpersDI.urlOpener()
            )
        ).eraseToAnyView()
    }
}

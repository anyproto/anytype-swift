import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func makeView() -> AnyView
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let modulesDI: ModulesDIProtocol

    init(
        coordinatorsDI: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        modulesDI: ModulesDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
        self.modulesDI = modulesDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
    @MainActor
    func makeView() -> AnyView {
        return ApplicationCoordinatorView(
            model: ApplicationCoordinatorViewModel(
                homeCoordinatorAssembly: self.coordinatorsDI.home(),
                deleteAccountModuleAssembly: self.modulesDI.deleteAccount(), 
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}

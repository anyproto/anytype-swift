import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func makeView() -> AnyView
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol

    init(
        coordinatorsDI: CoordinatorsDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
    @MainActor
    func makeView() -> AnyView {
        return ApplicationCoordinatorView(
            model: ApplicationCoordinatorViewModel(
                homeCoordinatorAssembly: self.coordinatorsDI.home(),
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}

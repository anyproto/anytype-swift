import Foundation
import SwiftUI

protocol ApplicationCoordinatorAssemblyProtocol: AnyObject {
    @MainActor
    func makeView() -> AnyView
}

final class ApplicationCoordinatorAssembly: ApplicationCoordinatorAssemblyProtocol {
    
    private let coordinatorsDI: CoordinatorsDIProtocol

    init(
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - ApplicationCoordinatorAssemblyProtocol
    
    @MainActor
    func makeView() -> AnyView {
        return ApplicationCoordinatorView(
            model: ApplicationCoordinatorViewModel(
                homeCoordinatorAssembly: self.coordinatorsDI.home()
            )
        ).eraseToAnyView()
    }
}

import Foundation
import SwiftUI

@MainActor
protocol SpacesManagerModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class SpacesManagerModuleAssembly: SpacesManagerModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpacesManagerModuleAssemblyProtocol
    
    func make() -> AnyView {
        SpacesManagerView(
            model: SpacesManagerViewModel(
                workspacesStorage: self.serviceLocator.workspaceStorage(),
                participantsSubscriptionServiceByAccount: self.serviceLocator.participantsSubscriptionServiceByAccount()
            )
        ).eraseToAnyView()
    }
}

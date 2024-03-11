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
                spacesSubscriptionService: SpaceManagerSpacesSubscriptionService(
                    subscriptionStorageProvider: self.serviceLocator.subscriptionStorageProvider(),
                    activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                    objectTypeProvider: self.serviceLocator.objectTypeProvider()
                ),
                workspaceService: self.serviceLocator.workspaceService(),
                participantsSubscriptionByAccountService: self.serviceLocator.participantsSubscriptionByAccountService()
            )
        ).eraseToAnyView()
    }
}

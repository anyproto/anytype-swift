import Foundation
import SwiftUI

protocol SpaceSettingsModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(output: SpaceSettingsModuleOutput?) -> AnyView
}

final class SpaceSettingsModuleAssembly: SpaceSettingsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceSettingsModuleAssemblyProtocol
    
    @MainActor
    func make(output: SpaceSettingsModuleOutput?) -> AnyView {
        return SpaceSettingsView(model: SpaceSettingsViewModel(
            activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
            subscriptionService: self.serviceLocator.singleObjectSubscriptionService(),
            objectActionsService: self.serviceLocator.objectActionsService(),
            relationDetailsStorage: self.serviceLocator.relationDetailsStorage(),
            workspaceService: self.serviceLocator.workspaceService(),
            accountManager: self.serviceLocator.accountManager(),
            accountParticipantsStorage: self.serviceLocator.accountParticipantStorage(),
            output: output
        )).eraseToAnyView()
    }
}

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
            objectActionsService: self.serviceLocator.objectActionsService(),
            relationDetailsStorage: self.serviceLocator.relationDetailsStorage(),
            workspaceService: self.serviceLocator.workspaceService(),
            accountManager: self.serviceLocator.accountManager(),
            participantSpacesStorage: self.serviceLocator.participantSpacesStorage(),
            output: output
        )).eraseToAnyView()
    }
}

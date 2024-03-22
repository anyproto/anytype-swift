import Foundation
import SwiftUI

@MainActor
protocol SpaceShareModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

@MainActor
final class SpaceShareModuleAssembly: SpaceShareModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceShareModuleAssemblyProtocol
    
    func make() -> AnyView {
        return SpaceShareView(
            model: SpaceShareViewModel(
                activeSpaceParticipantStorage: self.serviceLocator.activeSpaceParticipantStorage(),
                workspaceService: self.serviceLocator.workspaceService(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                deppLinkParser: self.serviceLocator.deepLinkParser()
            )
        ).eraseToAnyView()
    }
}

import Foundation
import SwiftUI

struct SpaceJoinModuleData: Identifiable {
    let id = UUID()
    let cid: String
    let key: String
}

@MainActor
protocol SpaceJoinModuleAssemblyProtocol: AnyObject {
    func make(data: SpaceJoinModuleData) -> AnyView
}

@MainActor
final class SpaceJoinModuleAssembly: SpaceJoinModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SpaceShareModuleAssemblyProtocol
    
    func make(data: SpaceJoinModuleData) -> AnyView {
        return SpaceJoinView(
            model: SpaceJoinViewModel(data: data, workspaceService: self.serviceLocator.workspaceService())
        ).eraseToAnyView()
    }
}

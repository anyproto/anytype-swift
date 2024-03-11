import Foundation
import SwiftUI

@MainActor
protocol SpaceShareCoordinatorAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

final class SpaceShareCoordinatorAssembly: SpaceShareCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SpaceShareCoordinatorAssemblyProtocol
    
    func make() -> AnyView {
        return SpaceShareCoordinatorView(
            model: SpaceShareCoordinatorViewModel(spaceShareModule: self.modulesDI.spareShare())
        ).eraseToAnyView()
    }
}

import SwiftUI

protocol MigrationGuideViewModuleAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class MigrationGuideViewModuleAssembly: MigrationGuideViewModuleAssemblyProtocol {
    
    // MARK: - MigrationGuideViewModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView  {
        return MigrationGuideView()
            .eraseToAnyView()
    }
}

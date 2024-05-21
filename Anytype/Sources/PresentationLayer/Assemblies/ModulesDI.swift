import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    // MARK: - ModulesDIProtocol
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly()
    }
}

extension Container {

    var legacyCreateObjectModuleAssembly: Factory<CreateObjectModuleAssemblyProtocol> {
        self { CreateObjectModuleAssembly() }
    }
}

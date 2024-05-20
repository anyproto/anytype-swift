import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            widgetsSubmoduleDI:  widgetsSubmoduleDI
        )
    }
}

extension Container {

    var legacyCreateObjectModuleAssembly: Factory<CreateObjectModuleAssemblyProtocol> {
        self { CreateObjectModuleAssembly() }
    }
}

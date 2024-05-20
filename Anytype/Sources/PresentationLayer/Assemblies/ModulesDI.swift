import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly()
    }
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            widgetsSubmoduleDI:  widgetsSubmoduleDI
        )
    }
}

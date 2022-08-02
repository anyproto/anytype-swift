import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    var relationValue: RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly()
    }
}

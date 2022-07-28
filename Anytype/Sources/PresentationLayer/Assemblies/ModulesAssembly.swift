import Foundation

protocol ModulesAssemblyProtocol: AnyObject {
    var relationValue: RelationValueModuleAssemblyProtocol { get }
}

final class ModulesAssembly: ModulesAssemblyProtocol {
    
    lazy var relationValue: RelationValueModuleAssemblyProtocol = {
        return RelationValueModuleAssembly()
    }()
}

import Foundation

protocol DIAssemblyProtocol: AnyObject {
    var coordinatorsAssembly: CoordinatorsAssemblyProtocol { get }
    var servicesAssembly: ServicesAssemblyProtocol { get }
    var modulesAssembly: ModulesAssemblyProtocol { get }
}

final class DIAssembly: DIAssemblyProtocol {
    
    lazy var coordinatorsAssembly: CoordinatorsAssemblyProtocol = {
        return CoordinatorsAssembly(servicesAssembly: servicesAssembly, modulesAssembly: modulesAssembly)
    }()
    
    lazy var servicesAssembly: ServicesAssemblyProtocol = {
        return ServicesAssembly()
    }()
    
    lazy var modulesAssembly: ModulesAssemblyProtocol = {
        return ModulesAssembly()
    }()
}

import Foundation

protocol CoordinatorsAssemblyProtocol: AnyObject {
    var relationValue: RelationValueCoordinatorAssemblyProtocol { get }
    var templates: TemplatesCoordinatorAssemblyProtocol { get }
    
    // Now like a coordinator. Migrate to isolated modules
    var browser: EditorBrowserAssembly { get }
    var editor: EditorAssembly { get }
    var homeViewAssemby: HomeViewAssembly { get }
}

final class CoordinatorsAssembly: CoordinatorsAssemblyProtocol {
    
    private let servicesAssembly: ServicesAssemblyProtocol
    private let modulesAssembly: ModulesAssemblyProtocol
    
    init(servicesAssembly: ServicesAssemblyProtocol, modulesAssembly: ModulesAssemblyProtocol) {
        self.servicesAssembly = servicesAssembly
        self.modulesAssembly = modulesAssembly
    }
    
    // MARK: - CoordinatorsAssemblyProtocol
    
    lazy var relationValue: RelationValueCoordinatorAssemblyProtocol = {
        return RelationValueCoordinatorAssembly(
            servicesAssembly: servicesAssembly,
            modulesAssembly: modulesAssembly
        )
    }()
    
    lazy var templates: TemplatesCoordinatorAssemblyProtocol = {
        return TemplatesCoordinatorAssembly(servicesAssembly: servicesAssembly, coordinatorsAssembly: self)
    }()
    
    lazy var browser: EditorBrowserAssembly = {
        return EditorBrowserAssembly(coordinatorsAssembly: self)
    }()
    
    lazy var editor: EditorAssembly = {
        return EditorAssembly(servicesAssembly: servicesAssembly, coordinatorsAssembly: self)
    }()
    
    lazy var homeViewAssemby: HomeViewAssembly = {
        return HomeViewAssembly(coordinatorsAssembly: self)
    }()
}

extension CoordinatorsAssembly {
    static func makeForPreview() -> CoordinatorsAssembly {
        CoordinatorsAssembly(servicesAssembly: ServicesAssembly(), modulesAssembly: ModulesAssembly())
    }
}

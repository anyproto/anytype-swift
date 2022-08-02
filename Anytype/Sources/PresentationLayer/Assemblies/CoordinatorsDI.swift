import Foundation

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    lazy var relationValue: RelationValueCoordinatorAssemblyProtocol = {
        return RelationValueCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI
        )
    }()
    
    lazy var templates: TemplatesCoordinatorAssemblyProtocol = {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }()
    
    lazy var browser: EditorBrowserAssembly = {
        return EditorBrowserAssembly(coordinatorsDI: self)
    }()
    
    lazy var editor: EditorAssembly = {
        return EditorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }()
    
    lazy var homeViewAssemby: HomeViewAssembly = {
        return HomeViewAssembly(coordinatorsDI: self)
    }()
}

extension CoordinatorsDI {
    static func makeForPreview() -> CoordinatorsDI {
        CoordinatorsDI(serviceLocator: ServiceLocator.shared, modulesDI: ModulesDI())
    }
}

import Foundation

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    var relationValue: RelationValueCoordinatorAssemblyProtocol {
        return RelationValueCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI
        )
    }
    
    var templates: TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }
    
    var editorPage: EditorPageCoordinatorAssemblyProtocol {
        return EditorPageCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self
        )
    }
    
    var linkToObject: LinkToObjectCoordinatorAssemblyProtocol {
        return LinkToObjectCoordinatorAssembly(
            serviceLocator: serviceLocator,
            modulesDI: modulesDI,
            coordinatorsID: self
        )
    }
    
    var browser: EditorBrowserAssembly {
        return EditorBrowserAssembly(coordinatorsDI: self)
    }
    
    var editor: EditorAssembly {
        return EditorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI)
    }
    
    var homeViewAssemby: HomeViewAssembly {
        return HomeViewAssembly(coordinatorsDI: self)
    }
}

extension CoordinatorsDI {
    static func makeForPreview() -> CoordinatorsDI {
        CoordinatorsDI(serviceLocator: ServiceLocator.shared, modulesDI: ModulesDI())
    }
}

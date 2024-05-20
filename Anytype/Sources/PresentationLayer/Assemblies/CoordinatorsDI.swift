import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    
    init(serviceLocator: ServiceLocator, modulesDI: ModulesDIProtocol) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
    }
    
    // MARK: - CoordinatorsDIProtocol
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(serviceLocator: serviceLocator, coordinatorsDI: self)
    }
    
    @MainActor
    func home() -> HomeCoordinatorAssemblyProtocol {
        return HomeCoordinatorAssembly(
            coordinatorsID: self,
            modulesDI: modulesDI
        )
    }

    func application() -> ApplicationCoordinatorAssemblyProtocol {
        return ApplicationCoordinatorAssembly(coordinatorsDI: self)
    }
    
    func editor() -> EditorCoordinatorAssemblyProtocol {
        EditorCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI)
    }

    func editorSet() -> EditorSetCoordinatorAssemblyProtocol {
        EditorSetCoordinatorAssembly(coordinatorsID: self, serviceLocator: serviceLocator)
    }

    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        EditorPageCoordinatorAssembly(coordinatorsID: self, modulesDI: modulesDI, serviceLocator: serviceLocator)
    }

    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol {
        SetObjectCreationSettingsCoordinatorAssembly(coordinatorsDI: self)
    }

    func editorPageModule() -> EditorPageModuleAssemblyProtocol {
        EditorPageModuleAssembly(serviceLocator: serviceLocator, coordinatorsDI: self, modulesDI: modulesDI)
    }
}

extension Container {
    var legacySetObjectCreationCoordinator: Factory<SetObjectCreationCoordinatorProtocol> {
        self { SetObjectCreationCoordinator() }
    }
    
    var legacySharingTip: Factory<SharingTipCoordinatorProtocol> {
        self { SharingTipCoordinator() }
    }
}

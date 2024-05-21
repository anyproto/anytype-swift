import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    // MARK: - CoordinatorsDIProtocol
    
    func templates() -> TemplatesCoordinatorAssemblyProtocol {
        return TemplatesCoordinatorAssembly(coordinatorsDI: self)
    }
    
    @MainActor
    func home() -> HomeCoordinatorAssemblyProtocol {
        return HomeCoordinatorAssembly(
            coordinatorsID: self
        )
    }

    func application() -> ApplicationCoordinatorAssemblyProtocol {
        return ApplicationCoordinatorAssembly(coordinatorsDI: self)
    }
    
    func editor() -> EditorCoordinatorAssemblyProtocol {
        EditorCoordinatorAssembly(coordinatorsID: self)
    }

    func editorSet() -> EditorSetCoordinatorAssemblyProtocol {
        EditorSetCoordinatorAssembly(coordinatorsID: self)
    }

    func editorPage() -> EditorPageCoordinatorAssemblyProtocol {
        EditorPageCoordinatorAssembly(coordinatorsID: self)
    }

    func setObjectCreationSettings() -> SetObjectCreationSettingsCoordinatorAssemblyProtocol {
        SetObjectCreationSettingsCoordinatorAssembly(coordinatorsDI: self)
    }

    func editorPageModule() -> EditorPageModuleAssemblyProtocol {
        EditorPageModuleAssembly(coordinatorsDI: self)
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

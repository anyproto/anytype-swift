import Foundation
import UIKit

final class CoordinatorsDI: CoordinatorsDIProtocol {
    
    // MARK: - CoordinatorsDIProtocol
    
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
}

extension Container {
    var legacySetObjectCreationCoordinator: Factory<SetObjectCreationCoordinatorProtocol> {
        self { SetObjectCreationCoordinator() }
    }
    
    var legacySharingTip: Factory<SharingTipCoordinatorProtocol> {
        self { SharingTipCoordinator() }
    }
    
    var legacyTemplatesCoordinator: Factory<TemplatesCoordinatorProtocol> {
        self { TemplatesCoordinator() }
    }
    
    var legacySetObjectCreationSettingsCoordinator: Factory<SetObjectCreationSettingsCoordinatorProtocol> {
        self { SetObjectCreationSettingsCoordinator() }
    }
}

import Foundation
import UIKit

extension Container {
    var legacySetObjectCreationCoordinator: Factory<any SetObjectCreationCoordinatorProtocol> {
        self { SetObjectCreationCoordinator() }
    }
    
    @MainActor
    var legacyTemplatesCoordinator: Factory<any TemplatesCoordinatorProtocol> {
        self { @MainActor in TemplatesCoordinator() }
    }
    
    var legacySetObjectCreationSettingsCoordinator: Factory<any SetObjectCreationSettingsCoordinatorProtocol> {
        self { SetObjectCreationSettingsCoordinator() }
    }
}

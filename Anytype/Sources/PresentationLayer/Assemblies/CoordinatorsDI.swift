import Foundation
import UIKit

extension Container {
    var legacySetObjectCreationCoordinator: Factory<any SetObjectCreationCoordinatorProtocol> {
        self { SetObjectCreationCoordinator() }
    }
    
    var legacyTemplatesCoordinator: Factory<any TemplatesCoordinatorProtocol> {
        self { TemplatesCoordinator() }
    }
    
    var legacySetObjectCreationSettingsCoordinator: Factory<any SetObjectCreationSettingsCoordinatorProtocol> {
        self { SetObjectCreationSettingsCoordinator() }
    }
}

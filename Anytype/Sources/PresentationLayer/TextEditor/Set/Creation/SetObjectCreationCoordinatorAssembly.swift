import Foundation
import UIKit
import SwiftUI

protocol SetObjectCreationCoordinatorAssemblyProtocol {
    func make() -> SetObjectCreationCoordinatorProtocol
}

final class SetObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol
    ) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetObjectCreationCoordinatorAssemblyProtocol
    
    func make() -> SetObjectCreationCoordinatorProtocol {
        SetObjectCreationCoordinator(
            createObjectModuleAssembly: modulesDI.createObject()
        )
    }
}

import Foundation
import SwiftUI

protocol PersonalizationModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(spaceId: String, output: PersonalizationModuleOutput?) -> AnyView
}

final class PersonalizationModuleAssembly: PersonalizationModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - PersonalizationModuleAssemblyProtocol
    
    @MainActor
    func make(spaceId: String, output: PersonalizationModuleOutput?) -> AnyView {
        return PersonalizationView(
            model: PersonalizationViewModel(
                spaceId: spaceId,
                objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                output: output
            )
        ).eraseToAnyView()
    }
}

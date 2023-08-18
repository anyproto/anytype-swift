import Foundation
import SwiftUI

protocol PersonalizationModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(spaceId: String, output: PersonalizationModuleOutput?) -> UIViewController
}

final class PersonalizationModuleAssembly: PersonalizationModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - PersonalizationModuleAssemblyProtocol
    
    @MainActor
    func make(spaceId: String, output: PersonalizationModuleOutput?) -> UIViewController {
        let model = PersonalizationViewModel(spaceId: spaceId, objectTypeProvider: serviceLocator.objectTypeProvider(), output: output)
        let view = PersonalizationView(model: model)
        return AnytypePopup(contentView: view)
    }
}

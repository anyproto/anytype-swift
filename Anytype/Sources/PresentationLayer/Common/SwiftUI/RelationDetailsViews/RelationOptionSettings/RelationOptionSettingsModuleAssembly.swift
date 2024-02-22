import Foundation
import SwiftUI

protocol RelationOptionSettingsModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationOptionSettingsConfiguration,
        completion: @escaping (_ optionParams: RelationOptionParameters) -> Void
    ) -> AnyView
}

final class RelationOptionSettingsModuleAssembly: RelationOptionSettingsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - RelationOptionSettingsModuleAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationOptionSettingsConfiguration,
        completion: @escaping (_ optionParams: RelationOptionParameters) -> Void
    ) -> AnyView {
        RelationOptionSettingsView(
            model: RelationOptionSettingsViewModel(
                configuration: configuration,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                completion: completion
            )
        ).eraseToAnyView()
    }
}

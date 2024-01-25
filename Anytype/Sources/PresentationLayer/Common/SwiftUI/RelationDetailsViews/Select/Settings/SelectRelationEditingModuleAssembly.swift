import Foundation
import SwiftUI

protocol SelectRelationSettingsModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        text: String?,
        color: Color?,
        mode: RelationSettingsMode,
        objectId: String,
        completion: @escaping (_ optionId: String) -> Void
    ) -> AnyView
}

final class SelectRelationSettingsModuleAssembly: SelectRelationSettingsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SelectRelationCreateModuleAssemblyProtocol
    
    @MainActor
    func make(
        text: String?,
        color: Color?,
        mode: RelationSettingsMode,
        objectId: String,
        completion: @escaping (_ optionId: String) -> Void
    ) -> AnyView {
        SelectRelationSettingsView(
            model: SelectRelationSettingsViewModel(
                text: text,
                color: color,
                mode: mode,
                relationsService: self.serviceLocator.relationService(objectId: objectId),
                completion: completion
            )
        ).eraseToAnyView()
    }
}

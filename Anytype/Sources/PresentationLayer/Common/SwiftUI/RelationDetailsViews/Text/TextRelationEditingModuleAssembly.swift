import Foundation
import SwiftUI

protocol TextRelationEditingModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration
    ) -> AnyView
}

final class TextRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - TextRelationEditingModuleAssemblyProtocol
    
    @MainActor
    func make(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration
    ) -> AnyView {
        TextRelationEditingView(
            viewModel: TextRelationEditingViewModel(
                text: text,
                type: type,
                config: config,
                service: self.serviceLocator.textRelationEditingService()
            )
        ).eraseToAnyView()
    }
}

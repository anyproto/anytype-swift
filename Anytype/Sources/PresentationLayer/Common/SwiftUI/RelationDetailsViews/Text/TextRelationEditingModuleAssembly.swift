import Foundation
import SwiftUI
import Services

@MainActor
protocol TextRelationEditingModuleAssemblyProtocol: AnyObject {
    func make(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration,
        objectDetails: ObjectDetails,
        output: TextRelationActionButtonViewModelDelegate?
    ) -> AnyView
}

@MainActor
final class TextRelationEditingModuleAssembly: TextRelationEditingModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - TextRelationEditingModuleAssemblyProtocol
    
    func make(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration,
        objectDetails: ObjectDetails,
        output: TextRelationActionButtonViewModelDelegate?
    ) -> AnyView {
        let builder = TextRelationActionViewModelBuilder() // TODO: Inject
        
        let actionsViewModels = builder.buildActionsViewModels(
            text: text,
            for: type,
            relationKey: config.relationKey,
            objectDetails: objectDetails,
            output: output
        )
        return TextRelationEditingView(
            viewModel: TextRelationEditingViewModel(
                text: text,
                type: type,
                config: config,
                actionsViewModels: actionsViewModels
            )
        ).eraseToAnyView()
    }
}

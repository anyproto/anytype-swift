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
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
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
        let actionsViewModel = buildActionsViewModel(
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
                actionsViewModel: actionsViewModel,
                service: self.serviceLocator.textRelationEditingService(),
                pasteboardHelper: self.serviceLocator.pasteboardHelper()
            )
        ).eraseToAnyView()
    }
    
    private func buildActionsViewModel(
        text: String?,
        for type: TextRelationViewType,
        relationKey: String,
        objectDetails: ObjectDetails,
        output: TextRelationActionButtonViewModelDelegate?
    ) -> [TextRelationActionViewModelProtocol] {
        
        guard let text, text.isNotEmpty else { return [] }
        
        let systemURLService = serviceLocator.systemURLService()
        switch type {
        case .text, .number, .numberOfDays:
            return []
        case .phone:
            return [
                TextRelationURLActionViewModel(
                    type: .phone,
                    systemURLService: systemURLService,
                    delegate: output
                ),
                TextRelationCopyActionViewModel(
                    type: .phone,
                    delegate: output
                )
            ]
        case .email:
            return [
                TextRelationURLActionViewModel(
                    type: .email,
                    systemURLService: systemURLService,
                    delegate: output
                ),
                TextRelationCopyActionViewModel(
                    type: .email,
                    delegate: output
                )
            ]
        case .url: 
            let actions: [TextRelationActionViewModelProtocol?] = [
                TextRelationURLActionViewModel(
                    type: .url,
                    systemURLService: systemURLService,
                    delegate: output
                ),
                TextRelationCopyActionViewModel(
                    type: .url,
                    delegate: output
                ),
                TextRelationReloadContentActionViewModel(
                    objectDetails: objectDetails,
                    relationKey: relationKey,
                    bookmarkService: serviceLocator.bookmarkService(),
                    delegate: output
                )
            ]
            return actions.compactMap { $0 }
        }
    }
}

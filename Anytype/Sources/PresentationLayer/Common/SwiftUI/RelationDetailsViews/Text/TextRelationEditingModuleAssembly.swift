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
                service: self.serviceLocator.textRelationEditingService()
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
        let alertOpener = uiHelpersDI.alertOpener()
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
                    alertOpener: alertOpener,
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
                    alertOpener: alertOpener,
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
                    alertOpener: alertOpener,
                    delegate: output
                ),
                TextRelationReloadContentActionViewModel(
                    objectDetails: objectDetails,
                    relationKey: relationKey,
                    bookmarkService: serviceLocator.bookmarkService(),
                    alertOpener: alertOpener
                )
            ]
            return actions.compactMap { $0 }
        }
    }
}

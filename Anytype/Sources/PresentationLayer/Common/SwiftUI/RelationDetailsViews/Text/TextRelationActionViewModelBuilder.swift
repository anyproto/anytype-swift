import Services


@MainActor
final class TextRelationActionViewModelBuilder {   
    nonisolated init() { }
    
    func buildActionsViewModels(
        text: String?,
        for type: TextRelationViewType,
        relationKey: String,
        objectDetails: ObjectDetails,
        output: TextRelationActionButtonViewModelDelegate?
    ) -> [TextRelationActionViewModelProtocol] {
        guard let text, text.isNotEmpty else { return [] }
        
        switch type {
        case .text, .number, .numberOfDays:
            return []
        case .phone:
            return [
                TextRelationURLActionViewModel(
                    type: .phone,
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
                    delegate: output
                ),
                TextRelationCopyActionViewModel(
                    type: .url,
                    delegate: output
                ),
                TextRelationReloadContentActionViewModel(
                    objectDetails: objectDetails,
                    relationKey: relationKey,
                    delegate: output
                )
            ]
            return actions.compactMap { $0 }
        }
    }
}

extension Container {
    var textRelationActionViewModelBuilder: Factory<TextRelationActionViewModelBuilder> {
        self { TextRelationActionViewModelBuilder() }.shared
    }
}

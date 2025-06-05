import Services


@MainActor
final class TextPropertyActionViewModelBuilder {   
    nonisolated init() { }
    
    func buildActionsViewModels(
        text: String?,
        for type: TextPropertyViewType,
        relationKey: String,
        objectDetails: ObjectDetails,
        output: (any TextPropertyActionButtonViewModelDelegate)?
    ) -> [any TextPropertyActionViewModelProtocol] {
        guard let text, text.isNotEmpty else { return [] }
        
        switch type {
        case .text, .number, .numberOfDays:
            return []
        case .phone:
            return [
                TextPropertyURLActionViewModel(
                    type: .phone,
                    delegate: output
                ),
                TextPropertyCopyActionViewModel(
                    type: .phone,
                    delegate: output
                )
            ]
        case .email:
            return [
                TextPropertyURLActionViewModel(
                    type: .email,
                    delegate: output
                ),
                TextPropertyCopyActionViewModel(
                    type: .email,
                    delegate: output
                )
            ]
        case .url:
            let actions: [(any TextPropertyActionViewModelProtocol)?] = [
                TextPropertyURLActionViewModel(
                    type: .url,
                    delegate: output
                ),
                TextPropertyCopyActionViewModel(
                    type: .url,
                    delegate: output
                ),
                TextPropertyReloadContentActionViewModel(
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
    var textRelationActionViewModelBuilder: Factory<TextPropertyActionViewModelBuilder> {
        self { TextPropertyActionViewModelBuilder() }.shared
    }
}

final class MentionAssembly {
    func controller(
        onMentionSelect: @escaping (MentionObject) -> Void,
        onDismiss: (() -> Void)?
    ) -> MentionsViewController {
        let service = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        let viewModel = MentionsViewModel(
            service: service,
            selectionHandler: onMentionSelect
        )
        let mentionsController = MentionsViewController(viewModel: viewModel, dismissAction: onDismiss)
        mentionsController.view.translatesAutoresizingMaskIntoConstraints = false
        
        return mentionsController
    }
}

final class MentionAssembly {
    func controller(
        onMentionSelect: @escaping (MentionObject) -> Void,
        onDismiss: (() -> Void)?
    ) -> MentionsViewController {
        let mentionService = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        
        let viewModel = MentionsViewModel(
            mentionService: mentionService,
            pageService: ServiceLocator.shared.pageService(),
            onSelect: onMentionSelect
        )
        let controller = MentionsViewController(viewModel: viewModel, dismissAction: onDismiss)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewModel.view = controller
        
        return controller
    }
}

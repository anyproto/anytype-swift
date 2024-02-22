final class MentionAssembly {
    func controller(
        document: BaseDocumentProtocol,
        onMentionSelect: @escaping (MentionObject) -> Void,
        onDismiss: (() -> Void)?
    ) -> MentionsViewController {
        let mentionService = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        
        let viewModel = MentionsViewModel(
            document: document,
            mentionService: mentionService,
            defaultObjectService: ServiceLocator.shared.defaultObjectCreationService(),
            onSelect: onMentionSelect
        )
        let controller = MentionsViewController(viewModel: viewModel, dismissAction: onDismiss)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        viewModel.view = controller
        
        return controller
    }
}

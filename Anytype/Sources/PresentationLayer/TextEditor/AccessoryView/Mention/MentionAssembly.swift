final class MentionAssembly {
    func controller(document: BaseDocumentProtocol) -> (MentionsViewController, MentionsViewModel) {
        let mentionService = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        
        let viewModel = MentionsViewModel(
            document: document,
            mentionService: mentionService,
            defaultObjectService: ServiceLocator.shared.defaultObjectCreationService()
        )
        let controller = MentionsViewController(viewModel: viewModel)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
                
        return (controller, viewModel)
    }
}

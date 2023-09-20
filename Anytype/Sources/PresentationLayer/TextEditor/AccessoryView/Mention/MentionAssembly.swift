final class MentionAssembly {
    func controller(document: BaseDocumentProtocol) -> (MentionsViewController, MentionsViewModel) {
        let mentionService = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        
        let viewModel = MentionsViewModel(
            document: document,
            mentionService: mentionService,
            pageService: ServiceLocator.shared.pageRepository()
        )
        let controller = MentionsViewController(viewModel: viewModel)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
                
        return (controller, viewModel)
    }
}

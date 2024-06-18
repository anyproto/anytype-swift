final class MentionAssembly {
    func controller(document: BaseDocumentProtocol) -> (MentionsViewController, MentionsViewModel) {
        let viewModel = MentionsViewModel(document: document)
        let controller = MentionsViewController(viewModel: viewModel)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
                
        return (controller, viewModel)
    }
}

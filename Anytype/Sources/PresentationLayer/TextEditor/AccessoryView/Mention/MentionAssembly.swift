@MainActor
final class MentionAssembly {
    func controller(document: some BaseDocumentProtocol, router: some EditorRouterProtocol) -> (MentionsViewController, MentionsViewModel) {
        let viewModel = MentionsViewModel(document: document, router: router)
        let controller = MentionsViewController(viewModel: viewModel)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
                
        return (controller, viewModel)
    }
}

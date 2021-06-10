
import UIKit

final class MentionView: DismissableInputAccessoryView {

    private weak var mentionsController: MentionsViewController?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let windowRootViewController = window?.rootViewController?.children.last else { return }
        addMentionsController(to: windowRootViewController)
    }
    
    private func addMentionsController(to controller: UIViewController) {
        let service = MentionObjectsService()
        let viewModel = MentionsViewModel(service: service)
        let mentionsController = MentionsViewController(style: .plain,
                                                        viewModel: viewModel)
        mentionsController.view.translatesAutoresizingMaskIntoConstraints = false
        controller.addChild(mentionsController)
        addSubview(mentionsController.view)
        NSLayoutConstraint.activate([
            (topSeparator?.bottomAnchor ?? topAnchor).constraint(equalTo: mentionsController.view.topAnchor),
            mentionsController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            mentionsController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            mentionsController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        mentionsController.didMove(toParent: controller)
        self.mentionsController = mentionsController
    }
    
}

extension MentionView: FilterableItemsHolder {
    
    func setFilterText(filterText: String) {
        mentionsController?.viewModel.setFilterString(filterText)
    }
    
    func isDisplayingAnyItems() -> Bool {
        return true
    }
}

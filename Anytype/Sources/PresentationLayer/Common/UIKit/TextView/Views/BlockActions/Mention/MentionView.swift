
import UIKit
import Amplitude


final class MentionView: DismissableInputAccessoryView {

    private weak var mentionsController: MentionsViewController?
    private let mentionsSelectionHandler: (MentionObject) -> Void
    
    init(frame: CGRect,
         dismissHandler: @escaping () -> Void,
         mentionsSelectionHandler: @escaping (MentionObject) -> Void) {
        self.mentionsSelectionHandler = mentionsSelectionHandler
        super.init(frame: frame, dismissHandler: dismissHandler)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let windowRootViewController = window?.rootViewController?.children.last else { return }
        addMentionsController(to: windowRootViewController)
    }

    override func didShow(from textView: UITextView) {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.popupMentionMenu)
    }
    
    private func addMentionsController(to controller: UIViewController) {
        let service = MentionObjectsService()
        let viewModel = MentionsViewModel(service: service,
                                          selectionHandler: mentionsSelectionHandler)
        let mentionsController = MentionsViewController(style: .plain,
                                                        viewModel: viewModel,
                                                        dismissAction: dismissHandler)
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

extension MentionView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        mentionsController?.viewModel.setFilterString(filterText)
    }
    
    func shouldContinueToDisplayView() -> Bool {
        return true
    }
}

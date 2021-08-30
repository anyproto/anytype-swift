
import UIKit
import Amplitude


protocol MentionViewDelegate: AnyObject {
    func selectMention(_ mention: MentionObject)
}

final class MentionView: DismissableInputAccessoryView {

    private weak var mentionsController: MentionsViewController?
    weak var delegate: MentionViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        let service = MentionObjectsService(searchService: ServiceLocator.shared.searchService())
        let viewModel = MentionsViewModel(service: service,
                                          selectionHandler: { [weak self] mentionObject in
                                            self?.delegate?.selectMention(mentionObject)
                                          })
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

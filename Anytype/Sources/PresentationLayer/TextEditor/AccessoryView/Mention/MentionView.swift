import UIKit
import AnytypeCore

protocol MentionViewDelegate: AnyObject {
    func selectMention(_ mention: MentionObject)
}

final class MentionView: DismissableInputAccessoryView {

    private let document: BaseDocumentProtocol
    private weak var mentionsController: MentionsViewController?
    weak var delegate: MentionViewDelegate?
    
    init(document: BaseDocumentProtocol, frame: CGRect) {
        self.document = document
        super.init(frame: frame)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let windowRootViewController = window?.rootViewController?.children.last else { return }
        addMentionsController(to: windowRootViewController)
        mentionsController?.viewModel.setFilterString("")
    }

    private func addMentionsController(to controller: UIViewController) {
        let mentionsController = MentionAssembly().controller(
            document: document,
            onMentionSelect: { [weak self] mentionObject in
                self?.delegate?.selectMention(mentionObject)
            },
            onDismiss: dismissHandler
        )
        
        controller.addChild(mentionsController)
        addSubview(mentionsController.view) {
            if FeatureFlags.ipadIncreaseWidth {
                $0.pinToSuperview(excluding: [.top])
            } else {
                $0.pinToSuperviewPreservingReadability(excluding: [.top])
            }
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
        mentionsController.didMove(toParent: controller)
        self.mentionsController = mentionsController
    }
    
}

extension MentionView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        mentionsController?.viewModel.setFilterString(filterText)
    }
}

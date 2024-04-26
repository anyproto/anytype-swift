import UIKit
import Services

protocol MentionViewDelegate: AnyObject {
    func selectMention(_ mention: MentionObject)
}

final class MentionView: DismissableInputAccessoryView {
    private var mentionsController: MentionsViewController?
    
    init(mentionsController: MentionsViewController, frame: CGRect) {
        self.mentionsController = mentionsController
        super.init(frame: frame)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let windowRootViewController = window?.rootViewController?.children.last else { return }
        addMentionsController(to: windowRootViewController)
    }
    
    private func addMentionsController(to controller: UIViewController) {
        guard let mentionsController else { return }
        
        controller.addChild(mentionsController)
        addSubview(mentionsController.view) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: topSeparator?.bottomAnchor ?? topAnchor)
        }
        mentionsController.didMove(toParent: controller)
    }
    
}

extension MentionView: FilterableItemsView {
    
    func setFilterText(filterText: String) {
        mentionsController?.viewModel.setFilterString(filterText)
    }
}

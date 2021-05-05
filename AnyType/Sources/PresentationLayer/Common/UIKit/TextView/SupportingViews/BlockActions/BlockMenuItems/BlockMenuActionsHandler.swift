
import UIKit

protocol BlockMenuActionsHandler {
    func handle(action: BlockActionType)
    func didShowMenuView(from textView: UITextView)
}

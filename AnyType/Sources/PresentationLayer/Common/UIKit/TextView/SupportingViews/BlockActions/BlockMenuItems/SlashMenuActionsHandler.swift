import UIKit

protocol SlashMenuActionsHandler {
    func handle(action: BlockActionType)
    func didShowMenuView(from textView: UITextView)
}

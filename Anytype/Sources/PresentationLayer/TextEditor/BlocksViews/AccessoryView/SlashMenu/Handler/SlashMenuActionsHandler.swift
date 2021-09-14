import UIKit

protocol SlashMenuActionsHandler {
    func handle(action: SlashAction)
    func didShowMenuView(from textView: UITextView)
}

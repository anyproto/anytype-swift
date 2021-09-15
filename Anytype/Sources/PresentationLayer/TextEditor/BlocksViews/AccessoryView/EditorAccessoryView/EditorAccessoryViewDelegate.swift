import UIKit

protocol EditorAccessoryViewDelegate: AnyObject {
    func showSlashMenuView(textView: UITextView)
    func showMentionsView(textView: UITextView)
}

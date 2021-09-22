import UIKit
import BlocksModels

enum EditorAccessoryViewAction {
    /// Slash button pressed
    case slashMenu
    /// Done button pressed
    case keyboardDismiss
    /// Show bottom sheet style menu
    case showStyleMenu
    /// Show mention menu
    case mention
}


final class EditorAccessoryViewModel {
    var block: BlockModelProtocol!
    
    weak var customTextView: CustomTextView?
    weak var delegate: EditorAccessoryViewDelegate?
    
    private let handler: EditorActionHandlerProtocol
    private let router: EditorRouter
    
    init(router: EditorRouter, handler: EditorActionHandlerProtocol) {
        self.router = router
        self.handler = handler
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let textView = customTextView?.textView, let delegate = delegate else {
            return
        }

        switch action {
        case .slashMenu:
            textView.insertStringAfterCaret(
                TextTriggerSymbols.slashMenu(textView: textView)
            )
            
            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )
            
            delegate.showSlashMenuView()
        case .showStyleMenu:
            router.showStyleMenu(information: block.information)
        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            textView.insertStringAfterCaret(
                TextTriggerSymbols.mention(textView: textView)
            )
            
            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )
            
            delegate.showMentionsView()
        }
    }
}

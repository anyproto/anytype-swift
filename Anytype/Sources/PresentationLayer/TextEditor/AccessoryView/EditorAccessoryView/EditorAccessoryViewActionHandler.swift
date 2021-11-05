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
    /// Enter editing mode
    case editingMode
}


final class EditorAccessoryViewModel {
    var info: BlockInformation!
    
    weak var textView: UITextView?
    weak var delegate: EditorAccessoryViewDelegate?
    
    private let handler: BlockActionHandlerProtocol
    private let router: EditorRouter
    
    init(router: EditorRouter, handler: BlockActionHandlerProtocol) {
        self.router = router
        self.handler = handler
    }
    
    func handle(_ action: EditorAccessoryViewAction) {
        guard let textView = textView, let delegate = delegate else {
            return
        }

        switch action {
        case .showStyleMenu:
            router.showStyleMenu(information: info)
        case .keyboardDismiss:
            UIApplication.shared.hideKeyboard()
        case .mention:
            textView.insertStringAfterCaret(
                TextTriggerSymbols.mention(prependSpace: shouldPrependSpace(textView: textView))
            )
            
            handler.changeText(textView.attributedText, info: info)
            
            delegate.showMentionsView()
        case .slashMenu:
            textView.insertStringAfterCaret(TextTriggerSymbols.slashMenu)
            handler.changeText(textView.attributedText, info: info)
            
            delegate.showSlashMenuView()
        case .editingMode:
            // Not implemented
            break
        }
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }
}

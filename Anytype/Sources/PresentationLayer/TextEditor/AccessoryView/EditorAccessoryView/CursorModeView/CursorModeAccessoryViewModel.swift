import UIKit
import BlocksModels
import AnytypeCore

enum CursorModeAccessoryViewAction {
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


final class CursorModeAccessoryViewModel {
    var info: BlockInformation!
    
    weak var textView: UITextView?
    weak var delegate: CursorModeAccessoryViewDelegate?

    private let onShowStyleMenu: RoutingAction<BlockInformation>
    private let onBlockSelection: RoutingAction<BlockInformation>
    
    private let handler: BlockActionHandlerProtocol

    init(
        handler: BlockActionHandlerProtocol,
        onShowStyleMenu: @escaping RoutingAction<BlockInformation>,
        onBlockSelection: @escaping RoutingAction<BlockInformation>
    ) {
        self.handler = handler
        self.onShowStyleMenu = onShowStyleMenu
        self.onBlockSelection = onBlockSelection
    }
    
    func handle(_ action: CursorModeAccessoryViewAction) {
        guard let textView = textView, let delegate = delegate else {
            return
        }

        switch action {
        case .showStyleMenu:
            onShowStyleMenu(info)
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
            textView.resignFirstResponder()
            onBlockSelection(info)
        }
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }
}

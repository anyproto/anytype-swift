import AnytypeCore
import UIKit
import BlocksModels

extension TextBlockContentView: CustomTextViewDelegate {    
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange) {
        switch change {
        case .become:
            blockDelegate.becomeFirstResponder(blockId: currentConfiguration.information.id)
        case .resign:
            blockDelegate.resignFirstResponder(blockId: currentConfiguration.information.id)
        }
    }
    
    func willBeginEditing() {
        blockDelegate.willBeginEditing(data: delegateData)
    }

    func didBeginEditing() {
        blockDelegate.didBeginEditing()
    }
    
    func didEndEditing() {
        blockDelegate.didEndEditing()
    }

    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .changeText:
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )

            blockDelegate.textDidChange()
        }
        return true
    }
    
    func changeTextStyle(text: NSAttributedString, attribute: BlockHandlerActionType.TextAttributesType, range: NSRange) {
        handler.changeTextStyle(
            text: text, attribute: attribute, range: range, blockId: currentConfiguration.information.id
        )
    }
    
    func changeLink(text: NSAttributedString, range: NSRange) {
        handler.showLinkToSearch(
            blockId: currentConfiguration.information.id,
            attrText: text,
            range: range
        )
    }
    
    func keyboardAction(_ action: CustomTextView.KeyboardAction) -> Bool {
        switch action {
        case .enterInsideContent,
             .enterAtTheEndOfContent,
             .enterAtTheBeginingOfContent:
            // In the case of frequent pressing of enter
            // we can send multiple split requests to middle
            // from the same block, it will leads to wrong order of blocks in array,
            // adding a delay makes impossible to press enter very often
            if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
                handler.handleKeyboardAction(action, info: currentConfiguration.information)
            }
            return false
        case .deleteOnEmptyContent, .deleteAtTheBeginingOfContent:
            handler.handleKeyboardAction(action, info: currentConfiguration.information)
            return true
        }
    }
    
    func showPage(blockId: BlockId) {
        guard let details = currentConfiguration.detailsStorage.get(id: blockId) else {
            // Deleted objects goes here
            return
        }
        
        if !details.isArchived && !details.isDeleted {
            currentConfiguration.showPage(blockId)
        }
    }
    
    func openURL(_ url: URL) {
        currentConfiguration.openURL(url)
    }
    
    func changeCaretPosition(_ range: NSRange) {
        handler.changeCarretPosition(range: range)
    }
    
    func shouldChangeText(range: NSRange, replacementText: String, mentionsHolder: Mentionable) -> Bool {
        blockDelegate.textWillChange(text: replacementText, range: range)
        let shouldChangeText = !mentionsHolder.removeMentionIfNeeded(text: replacementText)
        if !shouldChangeText {
            handler.handleAction(
                .textView(
                    action: .changeText(textView.textView.attributedText),
                    info: currentConfiguration.information
                ),
                blockId: currentConfiguration.information.id
            )
        }
        return shouldChangeText
    }
    
    // MARK: - Private
    private var blockDelegate: BlockDelegate {
        currentConfiguration.blockDelegate
    }
    
    private var handler: EditorActionHandlerProtocol {
        currentConfiguration.actionHandler
    }
    
    private var delegateData: TextBlockDelegateData {
        TextBlockDelegateData(
            textView: textView,
            info: currentConfiguration.information,
            text: currentConfiguration.content.anytypeText(using: currentConfiguration.detailsStorage)
        )
    }
}

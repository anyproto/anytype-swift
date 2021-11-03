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
        case let .keyboardAction(keyAction):
            switch keyAction {
            case .enterInsideContent,
                 .enterAtTheEndOfContent,
                 .enterAtTheBeginingOfContent:
                // In the case of frequent pressing of enter
                // we can send multiple split requests to middle
                // from the same block, it will leads to wrong order of blocks in array,
                // adding a delay makes impossible to press enter very often
                if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
                    handler.handleAction(
                        .textView(action: action, info: currentConfiguration.information),
                        blockId: currentConfiguration.information.id
                    )
                }
                return false
            default:
                break
            }
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )
        case .changeTextStyle:
            handler.handleAction(
                .textView(action: action, info: currentConfiguration.information),
                blockId: currentConfiguration.information.id
            )
        case let .shouldChangeText(range, replacementText, mentionsHolder):
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
        case let .changeLink(attrText, range):
            handler.showLinkToSearch(
                blockId: currentConfiguration.information.id,
                attrText: attrText,
                range: range
            )
        }
        return true
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

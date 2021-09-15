import AnytypeCore
import UIKit

extension TextBlockContentView: TextViewDelegate {
    func sizeChanged() {
        currentConfiguration.blockDelegate.blockSizeChanged()
    }
    
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        switch change {
        case .become:
            currentConfiguration.blockDelegate.becomeFirstResponder(for: currentConfiguration.block)
        case .resign:
            currentConfiguration.blockDelegate.resignFirstResponder()
        }
    }
    
    func willBeginEditing() {
        currentConfiguration.accessorySwitcher.didBeginEditing(
            textView: textView,
            delegate: self,
            information: currentConfiguration.information
        )
        currentConfiguration.blockDelegate.willBeginEditing()
    }

    func didBeginEditing() {
        currentConfiguration.blockDelegate.didBeginEditing()
    }

    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .changeText:
            currentConfiguration.accessorySwitcher.textDidChange(textView: textView.textView)

            currentConfiguration.actionHandler.handleAction(
                .textView(
                    action: action,
                    block: currentConfiguration.block
                ),
                blockId: currentConfiguration.information.id
            )
        case let .keyboardAction(keyAction):
            switch keyAction {
            case .enterInsideContent,
                 .enterAtTheEndOfContent,
                 .enterOnEmptyContent:
                // In the case of frequent pressing of enter
                // we can send multiple split requests to middle
                // from the same block, it will leads to wrong order of blocks in array,
                // adding a delay makes impossible to press enter very often
                if currentConfiguration.pressingEnterTimeChecker.exceedsTimeInterval() {
                    currentConfiguration.actionHandler.handleAction(
                        .textView(
                            action: action,
                            block: currentConfiguration.block
                        ),
                        blockId: currentConfiguration.information.id
                    )
                }
                return false
            default:
                break
            }
            currentConfiguration.actionHandler.handleAction(
                .textView(
                    action: action,
                    block: currentConfiguration.block
                ),
                blockId: currentConfiguration.information.id
            )
        case .changeTextStyle, .changeCaretPosition:
            currentConfiguration.actionHandler.handleAction(
                .textView(
                    action: action,
                    block: currentConfiguration.block
                ),
                blockId: currentConfiguration.information.id
            )
        case let .shouldChangeText(range, replacementText, mentionsHolder):
            currentConfiguration.accessorySwitcher.textWillChange(
                textView: textView.textView,
                replacementText: replacementText,
                range: range
            )
            let shouldChangeText = !mentionsHolder.removeMentionIfNeeded(
                replacementRange: range,
                replacementText: replacementText
            )
            if !shouldChangeText {
                currentConfiguration.actionHandler.handleAction(
                    .textView(
                        action: .changeText(textView.textView.attributedText),
                        block: currentConfiguration.block
                    ),
                    blockId: currentConfiguration.information.id
                )
            }
            return shouldChangeText
        case let .changeLink(attrText, range):
            let link: URL? = attrText.value(for: .link, range: range)
            currentConfiguration.accessorySwitcher.showURLInput(textView: textView.textView, url: link)
        case let .showPage(pageId):
            currentConfiguration.showPage(pageId)
        case let .openURL(url):
            currentConfiguration.openURL(url)
        }
        return true
    }
}

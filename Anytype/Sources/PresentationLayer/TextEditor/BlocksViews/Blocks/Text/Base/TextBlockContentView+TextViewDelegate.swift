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
        currentConfiguration.blockDelegate.willBeginEditing()
    }
    
    func didBeginEditing() {
        currentConfiguration.blockDelegate.didBeginEditing()
    }

    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .showStyleMenu:
            currentConfiguration.showStyleMenu(currentConfiguration.information)
        case .showMultiActionMenuAction:
            textView.shouldResignFirstResponder()
            let block = currentConfiguration.block
            currentConfiguration.actionHandler.handleAction(
                .textView(action: action, block: block),
                blockId: currentConfiguration.information.id
            )
        case .changeTextForStruct:
            fallthrough
        case .changeText:
            // TODO: Accessory need refactoring
            currentConfiguration.configureMentions(textView.textView)

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
            return !mentionsHolder.removeMentionIfNeeded(
                replacementRange: range,
                replacementText: replacementText
            )
        }
        return true
    }
}

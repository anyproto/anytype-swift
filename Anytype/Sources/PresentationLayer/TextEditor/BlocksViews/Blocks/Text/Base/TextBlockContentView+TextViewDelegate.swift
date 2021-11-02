import AnytypeCore
import UIKit

extension TextBlockContentView: CustomTextViewDelegate {
    func sizeChanged() {
        currentConfiguration.blockDelegate.blockSizeChanged()
    }
    
    func changeFirstResponderState(_ change: CustomTextViewFirstResponderChange) {
        switch change {
        case .become:
            currentConfiguration.blockDelegate.becomeFirstResponder(blockId: currentConfiguration.block.information.id)
        case .resign:
            currentConfiguration.blockDelegate.resignFirstResponder(blockId: currentConfiguration.block.information.id)
        }
    }
    
    func willBeginEditing() {
        currentConfiguration.accessoryDelegate.didBeginEditing(
            data: AccessoryViewSwitcherData(
                textView: textView,
                block: currentConfiguration.block,
                information: currentConfiguration.information,
                text: currentConfiguration.content.anytypeText(using: currentConfiguration.detailsStorage)
            )
        )
        currentConfiguration.blockDelegate.willBeginEditing()
    }

    func didBeginEditing() {
        currentConfiguration.blockDelegate.didBeginEditing()
    }

    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .changeText:
            currentConfiguration.actionHandler.handleAction(
                .textView(
                    action: action,
                    block: currentConfiguration.block
                ),
                blockId: currentConfiguration.information.id
            )

            currentConfiguration.accessoryDelegate.textDidChange()
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
            currentConfiguration.accessoryDelegate.textWillChange(
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
            currentConfiguration.actionHandler.showLinkToSearch(blockId: currentConfiguration.information.id,
                                                                attrText: attrText,
                                                                range: range)
        case let .showPage(pageId):
            guard let details = currentConfiguration.detailsStorage.get(id: pageId) else {
                // Deleted objects goes here
                return false
            }
            
            if !details.isArchived && !details.isDeleted {
                currentConfiguration.showPage(pageId)
            }
        case let .openURL(url):
            currentConfiguration.openURL(url)
        }
        return true
    }
}

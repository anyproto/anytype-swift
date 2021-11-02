import Foundation

protocol AccessoryTextViewDelegate {
    func didBeginEditing(data: AccessoryViewSwitcherData)
        
    func textDidChange()
    func textWillChange(replacementText: String, range: NSRange)
}

final class AccessoryViewStateManager: AccessoryTextViewDelegate {
    let switcher: AccessoryViewSwitcher
    
    private var data: AccessoryViewSwitcherData? { switcher.data }
    private var latestTextViewTextChange: TextViewTextChangeType?
    
    init(switcher: AccessoryViewSwitcher) {
        self.switcher = switcher
    }
    
    func didBeginEditing(data: AccessoryViewSwitcherData) {
        self.switcher.data = data
        
        switcher.accessoryView.update(block: data.block, textView: data.textView)
        switcher.showDefaultView()
        
        switcher.slashMenuView.update(block: data.block)
    }

    func textWillChange(replacementText: String, range: NSRange) {
        guard let data = data else { return }

        latestTextViewTextChange = data.textView.textView.textChangeType(
            changeTextRange: range,
            replacementText: replacementText
        )
    }

    func textDidChange() {
        switch switcher.activeView {
        case .`default`, .changeType:
            updateDefaultView()
            triggerTextActions()
        case .mention, .slashMenu:
            switcher.setTextToSlashOrMention()
        case .none, .urlInput:
            break
        }
    }
    
    private func updateDefaultView() {
        switcher.showDefaultView()
    }
    
    private func triggerTextActions() {
        guard latestTextViewTextChange == .typingSymbols else { return }
        
        displaySlashOrMentionIfNeeded()
    }
    
    private func displaySlashOrMentionIfNeeded() {
        guard let textView = data?.textView.textView else { return }
        guard let data = data, data.information.content.type != .text(.title) else { return }
        guard let textBeforeCaret = textView.textBeforeCaret else { return }
        guard let caretPosition = textView.caretPosition else { return }
        
        let carretOffset = textView.offsetFromBegining(caretPosition)
        let prependSpace = carretOffset > 1 // We need whitespace before / or @ if it is not 1st symbol
        
        if textBeforeCaret.hasSuffix(TextTriggerSymbols.slashMenu) {
            switcher.showSlashMenuView()
        } else if textBeforeCaret.hasSuffix(
            TextTriggerSymbols.mention(prependSpace: prependSpace)
        ) {
            switcher.showMentionsView()
        }
    }
}

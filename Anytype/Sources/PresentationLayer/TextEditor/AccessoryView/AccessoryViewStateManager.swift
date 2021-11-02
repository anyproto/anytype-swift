import Foundation
import UIKit

protocol AccessoryTextViewDelegate {
    func willBeginEditing(data: AccessoryViewSwitcherData)
    func didEndEditing()
    
    func textWillChange(replacementText: String, range: NSRange)
    func textDidChange()
}

final class AccessoryViewStateManager: AccessoryTextViewDelegate, EditorAccessoryViewDelegate {
    private var data: AccessoryViewSwitcherData? { switcher.data }
    private(set) var triggerSymbolPosition: UITextPosition?
    private var latestTextViewTextChange: TextViewTextChangeType?
    
    let switcher: AccessoryViewSwitcher
    let handler: EditorActionHandlerProtocol
    
    init(switcher: AccessoryViewSwitcher, handler: EditorActionHandlerProtocol) {
        self.switcher = switcher
        self.handler = handler
    }
    
    // MARK: - AccessoryTextViewDelegate
    func willBeginEditing(data: AccessoryViewSwitcherData) {
        switcher.updateData(data: data)
    }
    
    func didEndEditing() {
        switcher.restoreDefaultState()
    }

    func textWillChange(replacementText: String, range: NSRange) {
        latestTextViewTextChange = switcher.data?.textView.textView.textChangeType(
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
            setTextToSlashOrMention()
        case .none, .urlInput:
            break
        }
    }
    
    // MARK: - View Delegate
    func showSlashMenuView() {
        switcher.showSlashMenuView()
    }
    
    func showMentionsView() {
        switcher.showMentionsView()
    }
    
    // MARK: - Private
    private func setTextToSlashOrMention() {
        guard let filterText = searchText() else { return }
        
        switch switcher.activeView {
        case .mention(let view):
            view.setFilterText(filterText: filterText)
            dismissViewIfNeeded()
        case .slashMenu(let view):
            view.setFilterText(filterText: filterText)
            dismissViewIfNeeded(forceDismiss: view.shouldDismiss)
        default:
            break
        }
    }
    
    private func searchText() -> String? {
        guard let textView = data?.textView.textView else { return nil }
        
        guard let caretPosition = textView.caretPosition,
              let triggerSymbolPosition = triggerSymbolPosition,
              let range = textView.textRange(from: triggerSymbolPosition, to: caretPosition) else {
            return nil
        }
        return textView.text(in: range)
    }
    
    private func updateDefaultView() {
        switcher.showDefaultView()
    }
    
    private func triggerTextActions() {
        guard latestTextViewTextChange == .typingSymbols else { return }
        
        displaySlashOrMentionIfNeeded()
    }
    
    private var isTriggerSymbolDeleted: Bool {
        guard let triggerSymbolPosition = triggerSymbolPosition,
              let textView = data?.textView.textView,
              let caretPosition = textView.caretPosition else {
            return false
        }
        
        return textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending
    }
    
    func dismissViewIfNeeded(forceDismiss: Bool = false) {
        if forceDismiss || isTriggerSymbolDeleted {
            switcher.restoreDefaultState()
        }
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
        
        triggerSymbolPosition = textView.caretPosition
    }
}

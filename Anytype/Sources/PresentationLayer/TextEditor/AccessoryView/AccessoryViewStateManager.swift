import Foundation
import UIKit

protocol AccessoryViewStateManager {
    func willBeginEditing(data: TextBlockDelegateData)
    func didEndEditing()
    func textDidChange(changeType: TextChangeType)
}

final class AccessoryViewStateManagerImpl: AccessoryViewStateManager, EditorAccessoryViewDelegate {
    private var data: TextBlockDelegateData? { switcher.data }
    private(set) var triggerSymbolPosition: UITextPosition?
    
    let switcher: AccessoryViewSwitcher
    let handler: EditorActionHandlerProtocol
    
    init(switcher: AccessoryViewSwitcher, handler: EditorActionHandlerProtocol) {
        self.switcher = switcher
        self.handler = handler
    }
    
    // MARK: - AccessoryViewStateManager
    func willBeginEditing(data: TextBlockDelegateData) {
        switcher.updateData(data: data)
    }
    
    func didEndEditing() {
        switcher.restoreDefaultState()
    }

    func textDidChange(changeType: TextChangeType) {
        switch switcher.activeView {
        case .`default`, .changeType:
            updateDefaultView()
            triggerTextActions(changeType: changeType)
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
        guard let textView = data?.textView else { return nil }
        
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
    
    private func triggerTextActions(changeType: TextChangeType) {
        guard changeType == .typingSymbols else { return }
        
        displaySlashOrMentionIfNeeded()
    }
    
    private var isTriggerSymbolDeleted: Bool {
        guard let triggerSymbolPosition = triggerSymbolPosition,
              let textView = data?.textView,
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
        guard let textView = data?.textView else { return }
        guard let data = data, data.info.content.type != .text(.title) else { return }
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

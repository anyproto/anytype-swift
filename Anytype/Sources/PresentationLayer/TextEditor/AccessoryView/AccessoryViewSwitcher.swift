import UIKit
import BlocksModels
import Combine

protocol AccessoryViewSwitcherProtocol: EditorAccessoryViewDelegate {
    func showURLInput(url: URL?)
    func showDefaultView()
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    var triggerSymbolPosition: UITextPosition?
    
    var activeView = AccessoryViewType.none
    
    let accessoryView: EditorAccessoryView
    let mentionsView: MentionView
    let slashMenuView: SlashMenuView
    let changeTypeView: ChangeTypeAccessoryView
    let urlInputView: URLInputAccessoryView
    
    let handler: EditorActionHandlerProtocol
    let document: BaseDocumentProtocol
    
    var data: AccessoryViewSwitcherData?
    var cancellables = [AnyCancellable]()

    init(
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        accessoryView: EditorAccessoryView,
        changeTypeView: ChangeTypeAccessoryView,
        urlInputView: URLInputAccessoryView,
        handler: EditorActionHandlerProtocol,
        document: BaseDocumentProtocol
    ) {
        self.slashMenuView = slashMenuView
        self.accessoryView = accessoryView
        self.changeTypeView = changeTypeView
        self.mentionsView = mentionsView
        self.urlInputView = urlInputView
        self.document = document
        
        self.handler = handler
        
        setupDismissHandlers()
    }

    // MARK: - Public methods
    func showMentionsView() {
        showAccessoryView(.mention(mentionsView))
    }
    
    func showSlashMenuView() {
        showAccessoryView(.slashMenu(slashMenuView))
    }
    
    func showDefaultView() {
        showAccessoryView(
            document.isDocumentEmpty ? .changeType(changeTypeView) : .default(accessoryView)
        )
    }
    
    func showURLInput(url: URL?) {
        guard let data = data else { return }
        
        urlInputView.updateUrlData(.init(data: data, url: url))
        showAccessoryView(.urlInput(urlInputView))
        urlInputView.urlInputView.textField.becomeFirstResponder()
        cleanupDisplayedView()
    }
    
    // MARK: - Private methods
    private func cleanupDisplayedView() {
        slashMenuView.restoreDefaultState()
        
        activeView = .none
        triggerSymbolPosition = nil
    }
    
    func showAccessoryView(_ view: AccessoryViewType) {
        guard let textView = data?.textView.textView else { return }
        
        activeView = view
        triggerSymbolPosition = textView.caretPosition
        
        changeAccessoryView(view.view)
        
        if let view = view.view as? DismissableInputAccessoryView {
            view.didShow(from: textView)
        }
    }
    
    private func changeAccessoryView(_ accessoryView: UIView?) {
        guard let accessoryView = accessoryView,
              let textView = data?.textView.textView,
              textView.inputAccessoryView != accessoryView else {
            return
        }
        
        textView.inputAccessoryView = accessoryView
        
        accessoryView.transform = CGAffineTransform(translationX: 0, y: accessoryView.bounds.size.height)
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            accessoryView.transform = .identity
            textView.reloadInputViews()
            textView.window?.layoutIfNeeded()
        }
    }
    
    func setTextToSlashOrMention() {
        guard let filterText = searchText() else { return }
        
        switch activeView {
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
    
    func dismissViewIfNeeded(forceDismiss: Bool = false) {
        if forceDismiss || isTriggerSymbolDeleted {
            cleanupDisplayedView()
            showDefaultView()
        }
    }
    
    var isTriggerSymbolDeleted: Bool {
        guard let triggerSymbolPosition = triggerSymbolPosition,
              let textView = data?.textView.textView,
              let caretPosition = textView.caretPosition else {
            return false
        }
        
        return textView.compare(triggerSymbolPosition, to: caretPosition) == .orderedDescending
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
    
    private func setupDismissHandlers() {
        let dismiss = { [weak self] in
            guard let self = self else { return }
            self.cleanupDisplayedView()
            self.showDefaultView()
        }

        mentionsView.dismissHandler = dismiss
        slashMenuView.dismissHandler = dismiss
        urlInputView.dismissHandler = dismiss
    }
}

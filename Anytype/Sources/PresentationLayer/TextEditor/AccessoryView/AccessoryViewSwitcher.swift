import UIKit
import BlocksModels
import Combine

protocol AccessoryViewSwitcherProtocol {
    func setDelegate(_ delegate: MentionViewDelegate & EditorAccessoryViewDelegate)
    func updateData(data: AccessoryViewSwitcherData)
    
    func restoreDefaultState()
    
    func showURLInput(url: URL?)
    func showDefaultView()
    func showSlashMenuView()
    func showMentionsView()
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    private(set) var activeView = AccessoryViewType.none
    private(set) var data: AccessoryViewSwitcherData?
    
    private let accessoryView: EditorAccessoryView
    private let mentionsView: MentionView
    private let slashMenuView: SlashMenuView
    private let changeTypeView: ChangeTypeAccessoryView
    private let urlInputView: URLInputAccessoryView
    
    private let document: BaseDocumentProtocol

    init(
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        accessoryView: EditorAccessoryView,
        changeTypeView: ChangeTypeAccessoryView,
        urlInputView: URLInputAccessoryView,
        document: BaseDocumentProtocol
    ) {
        self.slashMenuView = slashMenuView
        self.accessoryView = accessoryView
        self.changeTypeView = changeTypeView
        self.mentionsView = mentionsView
        self.urlInputView = urlInputView
        self.document = document
        
        setupDismissHandlers()
    }

    // MARK: - Public methods
    func setDelegate(_ delegate: MentionViewDelegate & EditorAccessoryViewDelegate) {
        mentionsView.delegate = delegate
        accessoryView.setDelegate(delegate)
    }
    
    func updateData(data: AccessoryViewSwitcherData) {
        self.data = data
        
        accessoryView.update(info: data.info, textView: data.textView)
        slashMenuView.update(info: data.info)
        
        showDefaultView()
    }
    
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
        _ = urlInputView.becomeFirstResponder()
    }
    
    func restoreDefaultState() {
        slashMenuView.restoreDefaultState()
        showDefaultView()
    }
    
    // MARK: - Private methods
    private func showAccessoryView(_ view: AccessoryViewType) {
        guard let textView = data?.textView.textView else { return }
        
        activeView = view
        
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
    
    private func setupDismissHandlers() {
        let dismiss = { [weak self] in
            guard let self = self else { return }
            self.restoreDefaultState()
        }

        mentionsView.dismissHandler = dismiss
        slashMenuView.dismissHandler = dismiss
        urlInputView.dismissHandler = dismiss
    }
}

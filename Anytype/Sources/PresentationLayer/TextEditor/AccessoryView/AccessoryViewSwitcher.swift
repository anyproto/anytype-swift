import UIKit
import Services
import Combine

protocol AccessoryViewSwitcherProtocol {
    func update(with configuration: TextViewAccessoryConfiguration?)
    func clearAccessory()


    func showDefaultView()
    func showSlashMenuView()
    func showMentionsView()
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {

    private(set) var configuration: TextViewAccessoryConfiguration?
    private(set) var activeView = AccessoryViewType.none
    
    private var typePickerDismissedByUser = false
    private let document: BaseDocumentProtocol
    
    private let cursorModeAccessoryView: CursorModeAccessoryView
    private let mentionsView: MentionView
    private let slashMenuView: SlashMenuView
    private let changeTypeView: ChangeTypeAccessoryView
    private let markupAccessoryView: MarkupAccessoryView
    
    init(
        document: BaseDocumentProtocol,
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        cursorModeAccessoryView: CursorModeAccessoryView,
        markupAccessoryView: MarkupAccessoryView,
        changeTypeView: ChangeTypeAccessoryView
    ) {
        self.document = document
        self.slashMenuView = slashMenuView
        self.cursorModeAccessoryView = cursorModeAccessoryView
        self.markupAccessoryView = markupAccessoryView
        self.changeTypeView = changeTypeView
        self.mentionsView = mentionsView
        
        setupDismissHandlers()
    }

    // MARK: - Public methods

    func update(with configuration: TextViewAccessoryConfiguration?) {
        self.configuration = configuration
    }
    
    func showMentionsView() {
        showAccessoryView(.mention(mentionsView))
    }
    
    func showSlashMenuView() {
        showAccessoryView(.slashMenu(slashMenuView))
    }

    func showMarkupView() {
        showAccessoryView(.markup(markupAccessoryView))
    }

    func showDefaultView() {
        let isSelectType = document.details?.isSelectType ?? false
        let canSelectType = !document.permissions.canChangeType
        
        if isSelectType && canSelectType && !typePickerDismissedByUser {
            showAccessoryView(.changeType(changeTypeView), animation: activeView.animation)
        } else {
            showAccessoryView(.default(cursorModeAccessoryView), animation: activeView.animation)
            cursorModeAccessoryView.isHidden = false
        }
    }

    func clearAccessory() {
        cursorModeAccessoryView.isHidden = true
    }
    
    // MARK: - Private methods
    private func showAccessoryView(_ view: AccessoryViewType, animation: Bool = false) {
        guard let textView = configuration?.textView else { return }
        
        activeView = view
        
        changeAccessoryView(view.view, animation: animation)
        
        if let view = view.view as? DismissableInputAccessoryView {
            view.didShow(from: textView)
        }
    }
    
    private func changeAccessoryView(_ accessoryView: UIView?, animation: Bool = false) {
        guard let accessoryView = accessoryView,
              let textView = configuration?.textView,
              textView.inputAccessoryView != accessoryView else {
            return
        }
        
        textView.inputAccessoryView = accessoryView

        let reloadInputViews = {
            accessoryView.transform = .identity
            textView.reloadInputViews()
            textView.window?.layoutIfNeeded()
        }
        accessoryView.transform = CGAffineTransform(translationX: 0, y: accessoryView.bounds.size.height)

        if animation {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                reloadInputViews()
            }
        } else {
            reloadInputViews()
        }
    }
    
    private func setupDismissHandlers() {
        let dismiss = { [weak self] in
            guard let self = self else { return }
            self.showDefaultView()
        }

        changeTypeView.viewModel.onDoneButtonTap = { [weak self] in
            self?.typePickerDismissedByUser = true
            self?.showDefaultView()
        }

        mentionsView.dismissHandler = dismiss
        slashMenuView.dismissHandler = dismiss
    }
}

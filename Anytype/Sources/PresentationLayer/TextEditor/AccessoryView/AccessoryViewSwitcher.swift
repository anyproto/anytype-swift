import UIKit
import BlocksModels
import Combine

protocol AccessoryViewSwitcherProtocol {
    func updateData(data: TextBlockDelegateData)
    func clearAccessory(data: TextBlockDelegateData)

    func restoreDefaultState()

    func showDefaultView()
    func showSlashMenuView()
    func showMentionsView()
}

final class AccessoryViewSwitcher: AccessoryViewSwitcherProtocol {
    var onDoneButton: (() -> Void)?

    private(set) var activeView = AccessoryViewType.none
    private(set) var data: TextBlockDelegateData?
    
    private let cursorModeAccessoryView: CursorModeAccessoryView
    private let mentionsView: MentionView
    private let slashMenuView: SlashMenuView
    private let changeTypeView: ChangeTypeAccessoryView
    private let markupAccessoryView: MarkupAccessoryView
    
    private let document: BaseDocumentProtocol
    private var documentUpdateSubscription: AnyCancellable?
    private var didChangeTypeDismissByUser = false

    init(
        mentionsView: MentionView,
        slashMenuView: SlashMenuView,
        cursorModeAccessoryView: CursorModeAccessoryView,
        markupAccessoryView: MarkupAccessoryView,
        changeTypeView: ChangeTypeAccessoryView,
        document: BaseDocumentProtocol
    ) {
        self.slashMenuView = slashMenuView
        self.cursorModeAccessoryView = cursorModeAccessoryView
        self.markupAccessoryView = markupAccessoryView
        self.changeTypeView = changeTypeView
        self.mentionsView = mentionsView
        self.document = document
        
        setupDismissHandlers()
    }

    // MARK: - Public methods
    
    func updateData(data: TextBlockDelegateData) {
        self.data = data
        
        cursorModeAccessoryView.update(info: data.info, textView: data.textView, usecase: data.usecase)
        markupAccessoryView.update(info: data.info, textView: data.textView)
        slashMenuView.update(info: data.info, relations: document.parsedRelations.all)

        cursorModeAccessoryView.isHidden = false
        if data.textView.selectedRange.length != .zero {
            showMarkupView(range: data.textView.selectedRange)
        } else {
            showDefaultView()
        }
    }
    
    func showMentionsView() {
        showAccessoryView(.mention(mentionsView))
    }
    
    func showSlashMenuView() {
        showAccessoryView(.slashMenu(slashMenuView))
    }

    func showMarkupView(range: NSRange) {
        markupAccessoryView.selectionChanged(range: range)
        showAccessoryView(.markup(markupAccessoryView))
    }

    func updateSelection(range: NSRange) {
        markupAccessoryView.selectionChanged(range: range)
    }

    func showDefaultView() {
        markupAccessoryView.selectionChanged(range: .zero)

        let isSelectType = document.details?.isSelectType ?? false
        
        if isSelectType &&
            !document.objectRestrictions.objectRestriction.contains(.typechange),
            !didChangeTypeDismissByUser {
            showAccessoryView(.changeType(changeTypeView), animation: activeView.animation)
        } else {
            showAccessoryView(.default(cursorModeAccessoryView), animation: activeView.animation)
        }
    }

    func clearAccessory(data: TextBlockDelegateData) {
        slashMenuView.restoreDefaultState()
        data.textView.inputAccessoryView = nil
        
        cursorModeAccessoryView.isHidden = true
    }
    
    func restoreDefaultState() {
        slashMenuView.restoreDefaultState()
        showDefaultView()
    }
    
    // MARK: - Private methods
    private func showAccessoryView(_ view: AccessoryViewType, animation: Bool = false) {
        guard let textView = data?.textView else { return }
        
        activeView = view
        
        changeAccessoryView(view.view, animation: animation)
        
        if let view = view.view as? DismissableInputAccessoryView {
            view.didShow(from: textView)
        }
    }
    
    private func changeAccessoryView(_ accessoryView: UIView?, animation: Bool = false) {
        guard let accessoryView = accessoryView,
              let textView = data?.textView,
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
            self.restoreDefaultState()
        }

        changeTypeView.viewModel.onDoneButtonTap = { [weak self] in
            self?.didChangeTypeDismissByUser = true
            self?.showDefaultView()
            self?.onDoneButton?()
        }

        mentionsView.dismissHandler = dismiss
        slashMenuView.dismissHandler = dismiss
    }
}

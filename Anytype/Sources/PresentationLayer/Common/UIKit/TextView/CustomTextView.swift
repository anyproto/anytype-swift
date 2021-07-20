import Foundation
import UIKit
import Combine
import os
import BlocksModels

final class CustomTextView: UIView {
    
    weak var delegate: TextViewDelegate?
    weak var userInteractionDelegate: TextViewUserInteractionProtocol? {
        didSet {
            textView.userInteractionDelegate = userInteractionDelegate
            handler.delegate = userInteractionDelegate
        }
    }
    
    var textSize: CGSize?

    private(set) lazy var textView = createTextView()
    private(set) lazy var slashMenuView = createSlashMenu()
    private(set) lazy var mentionView = createMentionView()
    private(set) lazy var accessoryView = EditorAccessoryView(actionHandler: handler)
    private(set) lazy var handler = EditorAccessoryViewActionHandler(
        customTextView: self,
        switcher: inputSwitcher,
        delegate: userInteractionDelegate
    )
    
    let inputSwitcher = AccessoryViewSwitcher()
    
    private var firstResponderSubscription: AnyCancellable?

    let options: CustomTextViewOptions
    private let menuItemsBuilder: BlockActionsBuilder
    private let slashMenuActionsHandler: SlashMenuActionsHandler
    private let mentionsSelectionHandler: (MentionObject) -> Void
    
    init(
        options: CustomTextViewOptions,
        menuItemsBuilder: BlockActionsBuilder,
        slashMenuActionsHandler: SlashMenuActionsHandler,
        mentionsSelectionHandler: @escaping (MentionObject) -> Void
    ) {
        self.options = options
        self.menuItemsBuilder = menuItemsBuilder
        self.slashMenuActionsHandler = slashMenuActionsHandler
        self.mentionsSelectionHandler = mentionsSelectionHandler
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        .zero
    }
    
    func setupView() {
        textView.delegate = self

        addSubview(textView) {
            $0.pinToSuperview()
        }
        
        firstResponderSubscription = textView.firstResponderChangePublisher
            .sink { [weak self] change in
                self?.delegate?.changeFirstResponderState(change)
            }
    }
}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus {
    
    func shouldResignFirstResponder() {
        _ = textView.resignFirstResponder()
    }

    func setFocus(_ focus: BlockFocusPosition?) {
        guard let focus = focus else { return }
        
        textView.setFocus(focus)
    }

    func obtainFocusPosition() -> BlockFocusPosition? {
        guard textView.isFirstResponder else { return nil }
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}

// MARK: - Views

extension CustomTextView {
    func createTextView() -> TextViewWithPlaceholder {
        let textView = TextViewWithPlaceholder()
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }
    
    func createSlashMenu() -> SlashMenuView {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }
            self.inputSwitcher.cleanupDisplayedView()
            self.inputSwitcher.showEditingBars(customTextView: self)
        }

        let actionViewRect = CGRect(origin: .zero, size: Constants.menuActionsViewSize)
        return SlashMenuView(
            frame: actionViewRect,
            menuItems: menuItemsBuilder.makeBlockActionsMenuItems(),
            slashMenuActionsHandler: slashMenuActionsHandler,
            actionsMenuDismissHandler: dismissActionsMenu
        )
    }
    
    func createMentionView() -> MentionView {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }
            self.inputSwitcher.cleanupDisplayedView()
            self.inputSwitcher.showEditingBars(customTextView: self)
        }
        return MentionView(
            frame: CGRect(origin: .zero, size: Constants.menuActionsViewSize),
            dismissHandler: dismissActionsMenu,
            mentionsSelectionHandler: mentionsSelectionHandler)
    }
}


// MARK: - Constants
private extension CustomTextView {
    enum Constants {
        /// Minimum time interval to stay idle to handle consequent return key presses
        static let thresholdDelayBetweenConsequentReturnKeyPressing: CFTimeInterval = 0.5
        static let menuActionsViewSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.isFourInch ? 160 : 215
        )
    }
}

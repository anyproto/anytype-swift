import Foundation
import UIKit
import Combine
import os
import BlocksModels

extension CustomTextView {
    enum Constants {
        /// Minimum time interval to stay idle to handle consequent return key presses
        static let thresholdDelayBetweenConsequentReturnKeyPressing: CFTimeInterval = 0.5
        static let menuActionsViewSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.isFourInch ? 160 : 215
        )
    }
}

extension CustomTextView {
    struct Options {
        let createNewBlockOnEnter: Bool
        let autocorrect: Bool
    }
}


final class CustomTextView: UIView {
    private var firstResponderSubscription: AnyCancellable?
    
    weak var delegate: TextViewDelegate?
    weak var userInteractionDelegate: TextViewUserInteractionProtocol? {
        didSet {
            textView.userInteractionDelegate = userInteractionDelegate
        }
    }

    lazy var textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.textContainer.lineFragmentPadding = 0.0
        textView.isScrollEnabled = false
        textView.backgroundColor = nil
        textView.autocorrectionType = options.autocorrect ? .yes : .no
        return textView
    }()

    var textSize: CGSize?
    
    let editingToolbarAccessoryView = EditingToolbarView()
    let inputSwitcher = ActionsAndMarksPaneInputSwitcher()
    /// HighlightedAccessoryView
    private(set) lazy var highlightedAccessoryView = CustomTextView.HighlightedToolbar.AccessoryView()
    private(set) lazy var menuActionsAccessoryView: SlashMenuView = {
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
    }()

    private(set) lazy var mentionView: MentionView = {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }
            self.inputSwitcher.cleanupDisplayedView()
            self.inputSwitcher.showEditingBars(customTextView: self)
        }
        return MentionView(
            frame: CGRect(origin: .zero, size: Constants.menuActionsViewSize),
            dismissHandler: dismissActionsMenu,
            mentionsSelectionHandler: mentionsSelectionHandler)
    }()

    let options: Options
    private let menuItemsBuilder: BlockActionsBuilder
    private let slashMenuActionsHandler: SlashMenuActionsHandler
    private let mentionsSelectionHandler: (MentionObject) -> Void
    
    init(
        options: Options,
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
        configureEditingToolbarHandler(textView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override vars
    
    override var intrinsicContentSize: CGSize {
        .zero
    }

}

// MARK: - BlockTextViewInput

extension CustomTextView: TextViewManagingFocus, TextViewUpdatable {
    
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

    func apply(update: TextViewUpdate) {
        onUpdate(receive: update)
    }
    
    private func onUpdate(receive update: TextViewUpdate) {
        let text = NSMutableAttributedString(attributedString: update.attributedString)
        // TODO: Poem "Do we need to add font?"
        //
        // Actually, don't know. Should think about this problem ( when and where ) we should set font of attributed string.
        //
        // The main problem is that we should use `.font` to apply attributes to `NSAttributedString`.
        //
        // Example code below.
        //
        // let font: UIFont = self.textView.typingAttributes[.foregroundColor] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
        // text.addAttributes([.font : font], range: .init(location: 0, length: text.length))
        if text != textView.textStorage {
            textView.textStorage.setAttributedString(text)
        }
        
        /// We changed order, because textAlignment is a part of NSAttributedString.
        /// That means, we have to move processing of textAlignment to MarksStyle.
        /// It is a part of NSAttributedString attributes ( `NSParagraphStyle.alignment` ).
        ///
        textView.tertiaryColor = update.auxiliary.tertiaryColor
        textView.textAlignment = update.auxiliary.textAlignment
    }
}

// MARK: - Private extension

private extension CustomTextView {
    
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

    func configureEditingToolbarHandler(_ textView: UITextView) {
        self.editingToolbarAccessoryView.setActionHandler { [weak self] action in
            guard let self = self else { return }

            self.inputSwitcher.switchInputs(customTextView: self)

            switch action {
            case .slashMenu:
                textView.insertStringToAttributedString(
                    self.inputSwitcher.textToTriggerActionsViewDisplay
                )
                self.inputSwitcher.showAccessoryView(accessoryView: self.menuActionsAccessoryView,
                                                     textView: textView)
            case .multiActionMenu:
                self.userInteractionDelegate?.didReceiveAction(
                    .showMultiActionMenuAction
                )

            case .showStyleMenu:
                self.userInteractionDelegate?.didReceiveAction(.showStyleMenu)

            case .keyboardDismiss:
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            case .mention:
                textView.insertStringToAttributedString(self.inputSwitcher.textToTriggerMentionViewDisplay)
                self.inputSwitcher.showAccessoryView(accessoryView: self.mentionView,
                                                     textView: textView)
            }
        }
    }
}

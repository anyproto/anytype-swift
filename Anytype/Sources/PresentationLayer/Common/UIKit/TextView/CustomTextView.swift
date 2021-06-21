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

    let pressingEnterTimeChecker = TimeChecker()

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
    private(set) var menuActionsAccessoryView: SlashMenuView?

    private(set) lazy var mentionView: MentionView = {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }
            self.inputSwitcher.showEditingBars(customTextView: self)
        }
        return MentionView(
            frame: CGRect(origin: .zero, size: Constants.menuActionsViewSize),
            dismissHandler: dismissActionsMenu)
    }()

    let options: Options
    
    // MARK: - Initialization
    
    init(
        options: Options,
        menuItemsBuilder: BlockActionsBuilder,
        slashMenuActionsHandler: SlashMenuActionsHandler
    ) {
        self.options = options
        super.init(frame: .zero)

        setupView()
        configureMenuActionsAccessoryView(with: menuItemsBuilder, slashMenuActionsHandler: slashMenuActionsHandler)
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
        switch update {
        case let .text(value):
            // NOTE: Read these cases carefully.
            // 1. self.textView.textStorage.length == 0.
            // This case is simple. We should take _typingAttributes_ from textView and configure new attributed string.
            // 2. self.textView.textStorage.length != 0.
            // We should _replace_ text in range, however, if we don't check that our string is empty, we will configure incorrect attributes.
            // There is no way to set attributes for text, becasue it is inherited from attributes that are assigned to first character, that will be replaced.
            guard value != self.textView.textStorage.string else {
                /// Skip updating row without
                return
            }
            if self.textView.textStorage.length == 0 {
                let text = NSAttributedString(string: value, attributes: self.textView.typingAttributes)
                self.textView.textStorage.setAttributedString(text)
            }
            else {
                self.textView.textStorage.replaceCharacters(in: .init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        case let .attributedText(value):
            let text = NSMutableAttributedString(attributedString: value)

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
            guard text != self.textView.textStorage else {
                return
            }
            textView.textStorage.setAttributedString(text)
        case let .auxiliary(value):
            self.textView.tertiaryColor = value.tertiaryColor
            self.textView.textAlignment = value.textAlignment
        case let .payload(value):
            self.onUpdate(receive: .attributedText(value.attributedString))
            
            /// We changed order, because textAlignment is a part of NSAttributedString.
            /// That means, we have to move processing of textAlignment to MarksStyle.
            /// It is a part of NSAttributedString attributes ( `NSParagraphStyle.alignment` ).
            ///
            self.onUpdate(receive: .auxiliary(value.auxiliary))
        }
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
                switch change {
                case .become:
                    self?.delegate?.changeFirstResponderState(change)
                case .resign:
                    return
                }
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

    func configureMenuActionsAccessoryView(
        with menuItemsBuilder: BlockActionsBuilder,
        slashMenuActionsHandler: SlashMenuActionsHandler
    ) {
        let dismissActionsMenu = { [weak self] in
            guard let self = self else { return }

            self.inputSwitcher.showEditingBars(customTextView: self)
        }

        let actionViewRect = CGRect(origin: .zero, size: Constants.menuActionsViewSize)
        self.menuActionsAccessoryView = SlashMenuView(
            frame: actionViewRect,
            menuItems: menuItemsBuilder.makeBlockActionsMenuItems(),
            slashMenuActionsHandler: slashMenuActionsHandler,
            actionsMenuDismissHandler: dismissActionsMenu
        )
    }
}

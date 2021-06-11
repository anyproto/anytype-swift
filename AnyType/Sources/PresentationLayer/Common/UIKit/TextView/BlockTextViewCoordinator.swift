import BlocksModels
import UIKit
import Combine
import os

private extension LoggerCategory {
    static let textViewUIKitTextViewCoordinator: Self = "TextView.UIKitTextView.Coordinator"
}

final class BlockTextViewCoordinator: NSObject {
    
    // MARK: - Internal variables
    
    weak var userInteractionDelegate: TextViewUserInteractionProtocol?
    
    // MARK: - Private variables
    
    private var textSize: CGSize?
    private let textSizeChangeSubject: PassthroughSubject<CGSize, Never> = .init()
    private(set) lazy var textSizeChangePublisher: AnyPublisher<CGSize, Never> = self.textSizeChangeSubject.eraseToAnyPublisher()
    
    private let blockRestrictions: BlockRestrictions

    /// ContextualMenu Subscription
    private var contextualMenuSubscription: AnyCancellable?

    /// HighlightedAccessoryView
    private(set) lazy var highlightedAccessoryView = BlockTextView.HighlightedToolbar.AccessoryView()
    private var highlightedMarkStyleHandler: AnyCancellable?

    /// BlocksAccessoryView
    private(set) lazy var blocksAccessoryView = BlockTextView.BlockToolbar.AccessoryView()

    /// ActionsAccessoryView
    private(set) lazy var editingToolbarAccessoryView = EditingToolbarView()

    private(set) var menuActionsAccessoryView: BlockActionsView?
    
    private(set) lazy var mentionView: MentionView = {
        let dismissActionsMenu = { [weak self] in
            guard let self = self, let textView = self.textView else { return }
            self.inputSwitcher.showEditingBars(coordinator: self, textView: textView)
        }
        return MentionView(frame: CGRect(origin: .zero,
                                         size: Constants.menuActionsViewSize),
                           dismissHandler: dismissActionsMenu)
    }()

    private(set) var defaultKeyboardRect: CGRect = .zero
    private lazy var pressingEnterTimeChecker = TimeChecker(
        threshold: Constants.thresholdDelayBetweenConsequentReturnKeyPressing
    )

    private(set) weak var textView: UITextView?
    private lazy var inputSwitcher = ActionsAndMarksPaneInputSwitcher()

    // MARK: - Initializers
    
    init(blockRestrictions: BlockRestrictions,
         menuItemsBuilder: BlockActionsBuilder?,
         blockMenuActionsHandler: BlockMenuActionsHandler?
    ) {
        self.blockRestrictions = blockRestrictions
        
        super.init()
        
        tryToConfigureMenuActionsAccessoryView(with: menuItemsBuilder, blockMenuActionsHandler)
    }
    
}

// MARK: - Public Protocol

extension BlockTextViewCoordinator {
    
    // MARK: - Publishers / Actions Toolbar
    /// TODO:
    /// Rethink proper implementation of `Publishers.CombineLatest`.
    /// It will catch view value that we want to avoid, heh.
    /// Instead, think about `Coordinator` as a view-agnostic textView events handler.
    func configureEditingToolbarHandler(_ textView: UITextView) {
        self.editingToolbarAccessoryView.setActionHandler { [weak self] action in
            guard let self = self else { return }
            
            self.switchInputs(textView, accessoryView: nil, inputView: nil)

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
    
    // MARK: - ContextualMenuHandling
    /// TODO: Put textView into it.
    func configure(
        _ view: UITextView,
        contextualMenuStream: AnyPublisher<BlockTextView.ContextMenuAction, Never>
    ) {
        self.contextualMenuSubscription = Publishers.CombineLatest(
            Just(view),
            contextualMenuStream
        )
        .sink { [weak self] (view, action) in
            guard let self = self else { return }
            
            let range = view.selectedRange
            
            self.userInteractionDelegate?.didReceiveAction(
                BlockTextView.UserAction.inputAction(
                    BlockTextView.UserAction.InputAction.changeTextStyle(action, range)
                )
            )
            
            // looks like following functions do nothing
            self.switchInputs(view)
        }
    }
    
    func focusPosition() -> BlockFocusPosition? {
        guard let textView = self.textView, textView.isFirstResponder else { return nil }
        let caretLocation = textView.selectedRange.location
        if caretLocation == 0 {
            return .beginning
        }
        return .at(textView.selectedRange)
    }
}

// MARK: InnerTextView.Coordinator / Publishers

private extension BlockTextViewCoordinator {

    func publishToOuterWorldKeyboardAction(_ action: BlockTextView.UserAction.KeyboardAction?) {
        action.flatMap {
            self.userInteractionDelegate?.didReceiveAction(
                BlockTextView.UserAction.keyboardAction($0)
            )
        }
    }
    
    // MARK: - Publishers / Blocks Toolbar
        
    func configureMarkStylePublisher(_ view: UITextView) {
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { [weak self] (textView, action) in
            let attributedText = textView.textStorage
            let modifier = BlockTextView.MarkStyleModifier(
                attributedText: attributedText
            ).update(by: textView)
            
            Logger.create(.textViewUIKitTextViewCoordinator).debug("configureMarkStylePublisher \(String.init(describing: action))")
            
            switch action {
            case .keyboardDismiss: textView.endEditing(false)
            case let .bold(range):
                if let style = modifier.getMarkStyle(style: .bold(false), at: .range(range)) {
                    modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))

            case let .italic(range):
                if let style = modifier.getMarkStyle(style: .italic(false), at: .range(range)) {
                    modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))
                
            case let .strikethrough(range):
                if let style = modifier.getMarkStyle(style: .strikethrough(false), at: .range(range)) {
                    modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))
                
            case let .keyboard(range):
                if let style = modifier.getMarkStyle(style: .keyboard(false), at: .range(range)) {
                    modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))
                
            case let .linkView(range, builder):
                let style = modifier.getMarkStyle(style: .link(nil), at: .range(range))
                let string = attributedText.attributedSubstring(from: range).string
                let view = builder(string, style.flatMap({
                    switch $0 {
                    case let .link(link): return link
                    default: return nil
                    }
                }))
                self?.switchInputs(textView, accessoryView: view, inputView: nil)
                // we should apply selection attributes to indicate place where link will be applied.

            case let .link(range, url):
                guard range.length > 0 else { return }
                modifier.applyStyle(style: .link(url), rangeOrWholeString: .range(range))
                self?.updateHighlightedAccessoryView((range, attributedText))
                self?.switchInputs(textView)
                textView.becomeFirstResponder()
                
            case let .changeColorView(_, inputView):
                self?.switchInputs(textView, accessoryView: nil, inputView: inputView)

            case let .changeColor(range, textColor, backgroundColor):
                guard range.length > 0 else { return }
                if let textColor = textColor {
                    modifier.applyStyle(style: .textColor(textColor), rangeOrWholeString: .range(range))
                }
                if let backgroundColor = backgroundColor {
                    modifier.applyStyle(style: .backgroundColor(backgroundColor), rangeOrWholeString: .range(range))
                }
                return
            default: return
            }
        }
    }    
}

// MARK: Highlighted Accessory view handling

extension BlockTextViewCoordinator {
    
    func updateHighlightedAccessoryView(_ tuple: (NSRange, NSTextStorage)) {
        let (range, storage) = tuple
        highlightedAccessoryView.model.update(range: range, attributedText: storage)
    }
    
    func switchInputs(_ textView: UITextView) {
        inputSwitcher.switchInputs(self, textView: textView)
    }
    
}

// MARK: Input Switching
private extension BlockTextViewCoordinator {
    
    func switchInputs(_ textView: UITextView,
                      animated: Bool = false,
                      accessoryView: UIView?,
                      inputView: UIView?) {
        inputSwitcher.switchInputs(
            self.defaultKeyboardRect.size,
            animated: animated,
            textView: textView,
            accessoryView: accessoryView,
            inputView: inputView
        )
    }
    
}

// MARK: - UITextViewDelegate

extension BlockTextViewCoordinator: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard blockRestrictions.canCreateBlockBelowOnEnter else { return true }

        // In the case of frequent pressing of enter
        // we can send multiple split requests to middle
        // from the same block, it will leads to wrong order of blocks in array,
        // adding a delay in UITextView makes impossible to press enter very often
        inputSwitcher.textViewChange = textView.textChangeType(changeTextRange: range, replacementText: text)
        
        if text == "\n" && !self.pressingEnterTimeChecker.exceedsTimeInterval() {
            return false
        }
        
        BlockTextView.UserAction.KeyboardAction.convert(
            textView,
            shouldChangeTextIn: range,
            replacementText: text
        ).flatMap {
            self.userInteractionDelegate?.didReceiveAction(
                BlockTextView.UserAction.keyboardAction($0)
            )
        }
        
        if text == "\n" {
            // we should return false and perform update by ourselves.
            switch (textView.text, range) {
            case (_, .init(location: 0, length: 0)):
                /// At the beginning
                /// We shouldn't set text, of course.
                /// It is correct logic only if we insert new text below our text.
                /// For now, we insert text above our text.
                ///
                /// TODO: Uncomment when you set split to type `.bottom`, not `.top`.
                /// textView.text = ""
                // "We only should remove text if our split operation will insert blocks at bottom, not a top. At top it works without resetting text."
                return false
            case let (source, at) where source?.count == at.location + at.length:
                return false
            case let (source, at):
                if let source = source, let theRange = Range(at, in: source) {
                    textView.text = source.replacingCharacters(in: theRange, with: "\n").split(separator: "\n").first.flatMap(String.init)
                }
                return false
            }
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.switchInputs(textView)
        
        if textView.isFirstResponder {
            self.userInteractionDelegate?.didReceiveAction(
                .changeCaretPosition(textView.selectedRange)
            )
        }
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView = textView
        
        if textView.inputAccessoryView.isNil {
            textView.inputAccessoryView = self.editingToolbarAccessoryView
        }
        
        self.switchInputs(textView)
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textSize = textView.intrinsicContentSize
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.textView = textView
        let contentSize = textView.intrinsicContentSize
        self.userInteractionDelegate?.didReceiveAction(
            BlockTextView.UserAction.inputAction(.changeText(textView.attributedText))
        )
        self.switchInputs(textView)
        
        guard self.textSize?.height != contentSize.height else { return }
        self.textSize = contentSize
        
        DispatchQueue.main.async {
            self.textSizeChangeSubject.send(contentSize)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputSwitcher.textViewChange = nil
    }
}

// MARK: - InnerTextView.Coordinator / UIGestureRecognizerDelegate

extension BlockTextViewCoordinator: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func tap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            gestureRecognizer.view?.becomeFirstResponder()
        default: break
        }
        
        Logger.create(.textViewUIKitTextViewCoordinator).debug(
            "\(self) tap: \(gestureRecognizer.state.debugString)"
        )
    }
}

// MARK: - Private extension

private extension BlockTextViewCoordinator {
    
    func tryToConfigureMenuActionsAccessoryView(with menuItemsBuilder: BlockActionsBuilder?, _ blockMenuActionsHandler: BlockMenuActionsHandler?) {
        guard
            let menuItemsBuilder = menuItemsBuilder,
            let blockMenuActionsHandler = blockMenuActionsHandler
        else { return }
        
        let dismissActionsMenu = { [weak self] in
            guard let self = self, let textView = self.textView else { return }
            
            self.inputSwitcher.showEditingBars(coordinator: self, textView: textView)
        }

        let actionViewRect = CGRect(origin: .zero, size: Constants.menuActionsViewSize)
        self.menuActionsAccessoryView = BlockActionsView(
            frame: actionViewRect,
            menuItems: menuItemsBuilder.makeBlockActionsMenuItems(),
            blockMenuActionsHandler: blockMenuActionsHandler,
            actionsMenuDismissHandler: dismissActionsMenu
        )
    }
    
}

// MARK: - Constants

private extension BlockTextViewCoordinator {
    
    enum Constants {
        /// Minimum time interval to stay idle to handle consequent return key presses
        static let thresholdDelayBetweenConsequentReturnKeyPressing: CFTimeInterval = 0.5
        static let menuActionsViewSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.isFourInch ? 160 : 215
        )
    }
    
}

// MARK: - UIGestureRecognizer.State

private extension UIGestureRecognizer.State {
    
    var debugString: String {
        switch self {
        case .possible: return ".possible"
        case .began: return ".began"
        case .changed: return ".changed"
        case .ended: return ".ended|.recognized" // Same sa .recognized
        case .cancelled: return ".cancelled"
        case .failed: return ".failed"
        @unknown default: return "TheUnknown"
        }
    }
    
}

// MARK: - MarksPane.Main.Panes.StylePane extensions

private extension MarksPane.Main.Panes.StylePane.FontStyle.Action {
    
    var asMarkStyle: BlockTextView.MarkStyle {
        switch self {
        case .bold: return .bold(false)
        case .italic: return .italic(false)
        case .strikethrough: return .strikethrough(false)
        case .keyboard: return .keyboard(false)
        }
    }
    
}

private extension MarksPane.Main.Panes.StylePane.Alignment.Action {
    
    var asTextAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
    
}

// MARK: - BlockTextView.ContextualMenuAction

private extension BlockTextView.ContextMenuAction {
    
    var asCategory: MarksPane.Main.Section.Category? {
        return nil
    }
    
}

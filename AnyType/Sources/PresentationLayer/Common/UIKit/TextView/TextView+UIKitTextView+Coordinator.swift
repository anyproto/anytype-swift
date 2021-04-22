//
//  TextView+UIKitTextView+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import BlocksModels
import UIKit
import Combine
import os

fileprivate typealias Namespace = TextView.UIKitTextView
fileprivate typealias FileNamespace = Namespace.Coordinator

private extension LoggerCategory {
    static let textViewUIKitTextViewCoordinator: Self = "TextView.UIKitTextView.Coordinator"
}

extension Namespace {
    final class Coordinator: NSObject {
        
        enum Constants {
            /// Minimum time interval to stay idle to handle consequent return key presses
            static let thresholdDelayBetweenConsequentReturnKeyPressing: CFTimeInterval = 0.5
        }
        // MARK: Aliases
        typealias TheTextView = TextView.UIKitTextView
        typealias HighlightedAccessoryView = TextView.HighlightedToolbar.AccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView
        typealias MarksToolbarInputView = MarksPane.Main.ViewModelHolder
        /// TODO: Should we store variables here?
        /// Because, we have also `viewModel`.
        /// Maybe we need remove these variables?
        private var attributedTextSubject: PassthroughSubject<NSAttributedString?, Never> = .init()
        private var textAlignmentSubject: PassthroughSubject<NSTextAlignment?, Never> = .init()
        private(set) var attributedTextPublisher: AnyPublisher<NSAttributedString?, Never> = .empty()
        private(set) var textAlignmentPublisher: AnyPublisher<NSTextAlignment?, Never> = .empty()
        private var textSize: CGSize?
        private let textSizeChangeSubject: PassthroughSubject<CGSize, Never> = .init()
        private(set) lazy var textSizeChangePublisher: AnyPublisher<CGSize, Never> = self.textSizeChangeSubject.eraseToAnyPublisher()
        private weak var userInteractionDelegate: TextViewUserInteractionProtocol?
        
        /// TextStorage Subscription
        private var textStorageSubscription: AnyCancellable?
        
        /// ContextualMenu Subscription
        private var contextualMenuSubscription: AnyCancellable?
        
        /// HighlightedAccessoryView
        private(set) lazy var highlightedAccessoryView = HighlightedAccessoryView()
        private var highlightedMarkStyleHandler: AnyCancellable?
        
        /// Whole mark style handler
        private var wholeMarkStyleHandler: AnyCancellable?
        
        /// BlocksAccessoryView
        private(set) lazy var blocksAccessoryView = BlockToolbarAccesoryView()
        private var blocksAccessoryViewHandler: AnyCancellable?
        private var blocksUserActionsHandler: AnyCancellable?
        
        /// ActionsAccessoryView
        private(set) lazy var editingToolbarAccessoryView = EditingToolbarView()
        private var actionsToolbarAccessoryViewHandler: AnyCancellable?
        private var actionsToolbarUserActionsHandler: AnyCancellable?
        
        /// MarksInputView
        private(set) lazy var marksToolbarInputView = MarksToolbarInputView()
        private var marksToolbarHandler: AnyCancellable? // Hm... we need what?
        /// We need handler which connects contextual menu action and will handle "changing" of value in marksToolbar and also trigger it appearance.
        /// Also, we need handler which connects marks processing.
        /// And also, we need a handler which updates current state of marks ( like updateHighlightingMenu )
        
        
        private var keyboardObserverHandler: AnyCancellable?
        private(set) var defaultKeyboardRect: CGRect = .zero
        private lazy var pressingEnterTimeChecker = TimeChecker(threshold: Constants.thresholdDelayBetweenConsequentReturnKeyPressing)
        
        private let inputSwitcher: ActionsAndMarksPaneInputSwitcher
        
        init(menuItemsBuilder: BlockActionsBuilder, blockMenuActionsHandler: BlockMenuActionsHandler) {
            self.inputSwitcher = ActionsAndMarksPaneInputSwitcher(menuItemsBuilder: menuItemsBuilder,
                                                                  blockMenuActionsHandler: blockMenuActionsHandler)
        }
    }
}

// MARK: - Public Protocol
extension FileNamespace {
    func configure(_ delegate: TextViewUserInteractionProtocol?) -> Self {
        self.userInteractionDelegate = delegate
        return self
    }
    
    // MARK: - Publishers / Actions Toolbar
    /// TODO:
    /// Rethink proper implementation of `Publishers.CombineLatest`.
    /// It will catch view value that we want to avoid, heh.
    /// Instead, think about `Coordinator` as a view-agnostic textView events handler.
    ///
    func configureEditingToolbarHandler(_ textView: UITextView) {
        self.editingToolbarAccessoryView.setActionHandler { [weak self] action in
            self?.switchInputs(textView, accessoryView: nil, inputView: nil)

            switch action {
            case .addBlock:
                self?.publishToOuterWorld(.addBlockAction(.addBlock))
            case .multiActionMenu:
                self?.publishToOuterWorld(.showMultiActionMenuAction(.showMultiActionMenu))
            case .keyboardDismiss:
                UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    // MARK: - Publishers / Marks Pane
    /// We could apply new attributes somewhere else.
    /// 
    /// TODO:
    /// Remove it from here.
    ///
    func configureMarksPanePublisher(_ view: UITextView) {
        self.marksToolbarHandler = Publishers.CombineLatest(Just(view), self.marksToolbarInputView.viewModel.userAction).sink { [weak self] (value) in
            let (textView, action) = value
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            
            Logger.create(.textViewUIKitTextViewCoordinator).debug("MarksPane action \(String.init(describing: action))")
            
            switch action {
            case let .style(range, attribute):
                guard range.length > 0 else { return }
                switch attribute {
                case let .fontStyle(attribute):
                    let theMark = ActionsToMarkStyleConverter.emptyMark(from: attribute)
                    if let style = modifier.getMarkStyle(style: theMark, at: .range(range)) {
                        _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                    }
                case let .alignment(attribute):
                    textView.textAlignment = ActionsToMarkStyleConverter.textAlignment(from: attribute)
                }
                self?.updateMarksInputView((range, attributedText, textView))
                
            case let .textColor(range, attribute):
                guard range.length > 0 else { return }
                
                switch attribute {
                case let .setColor(color):
                    _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .range(range))
                    self?.updateMarksInputView((range, attributedText))
                }
                
            case let .backgroundColor(range, attribute):
                guard range.length > 0 else { return }
                
                switch attribute {
                case let .setColor(color):
                    _ = modifier.applyStyle(style: .backgroundColor(color), rangeOrWholeString: .range(range))
                    self?.updateMarksInputView((range, attributedText))
                }
            }
        }
    }
    
    // MARK: - ContextualMenuHandling
    /// TODO: Put textView into it.
    func configured(_ view: UITextView, contextualMenuStream: AnyPublisher<TextView.UIKitTextView.ContextualMenu.Action, Never>) -> Self {
        self.contextualMenuSubscription = Publishers.CombineLatest(Just(view), contextualMenuStream).sink { [weak self] (tuple) in
            let (view, action) = tuple
            let range = view.selectedRange
            let attributedText = view.textStorage
            self?.updateMarksInputView((range, attributedText, view, action))
            self?.switchInputs(view)
        }
        return self
    }
}

private extension FileNamespace {
    func configureKeyboardNotificationsListening() {
        /// TODO: Refactor
        /// Shit. You can't `observe` `Published` value. It will be observed on the same thread. Instead, you have to `receive(on:)` it on main/background thread.
        // "Keyboard observing is incorrect. You have to either change it by modifier .receive(on:) or you have to cache it in more 'mutable' way.")
        self.keyboardObserverHandler = KeyboardObserver.default.$keyboardInformation.map(\.keyboardRect).filter({
            [weak self] value in
            value != .zero && self?.defaultKeyboardRect == .zero
        }).sink{ [weak self] value in self?.defaultKeyboardRect = value }
    }
}

// MARK: InnerTextView.Coordinator / Publishers
private extension FileNamespace {
    // MARK: - Publishers
    // MARK: - Publishers / Outer world
    
    func publishToOuterWorld(_ action: TextView.UserAction?) {
        action.flatMap({self.userInteractionDelegate?.didReceiveAction($0)})
    }
    func publishToOuterWorld(_ action: TextView.UserAction.BlockAction?) {
        action.flatMap(TextView.UserAction.blockAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.MarksAction?) {
        action.flatMap(TextView.UserAction.marksAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.InputAction?) {
        action.flatMap(TextView.UserAction.inputAction).flatMap(publishToOuterWorld)
    }
    func publishToOuterWorld(_ action: TextView.UserAction.KeyboardAction?) {
        action.flatMap(TextView.UserAction.keyboardAction).flatMap(publishToOuterWorld)
    }
    
    // MARK: - Publishers / Blocks Toolbar
    func configureBlocksToolbarHandler(_ view: UITextView) {
        self.blocksAccessoryViewHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.$userAction).sink(receiveValue: { [weak self] (value) in
            let (textView, action) = value
            
            guard action.action != .keyboardDismiss else {
                textView.endEditing(false)
                return
            }
            
            self?.switchInputs(textView, accessoryView: nil, inputView: action.view)
        })
        
        // TODO: Add other user interaction publishers.
        // 1. Add hook that will send this data to delegate.
        // 2. Add delegate that will take UserAction like delegate?.onUserAction(UserAction)
        // 3. Add another delegate that will "wraps" UserAction with information about block ( first delegate IS a observableModel or even just ObservableObject or @binding... )
        // 4. Second delegate is a documentViewModel ( so, it needs information about block if available.. )
        // 5. Add hook to receive user key inputs and context of current text View. ( enter may behave different ).
        // 6. Add hook that will catch marks styles. ( special convert for links and colors )
        self.blocksUserActionsHandler = self.blocksAccessoryView.model.allInOnePublisher.sink { [weak self] value in
            // now tell outer world that we are ready to process actions.
            // ...
            self?.publishToOuterWorld(value)
        }
    }
        
    func configureMarkStylePublisher(_ view: UITextView) {
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { [weak self] (textView, action) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            
            Logger.create(.textViewUIKitTextViewCoordinator).debug("configureMarkStylePublisher \(String.init(describing: action))")
            
            switch action {
            case .keyboardDismiss: textView.endEditing(false)
            case let .bold(range):
                if let style = modifier.getMarkStyle(style: .bold(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))

            case let .italic(range):
                if let style = modifier.getMarkStyle(style: .italic(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))
                
            case let .strikethrough(range):
                if let style = modifier.getMarkStyle(style: .strikethrough(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self?.updateHighlightedAccessoryView((range, attributedText))
                
            case let .keyboard(range):
                if let style = modifier.getMarkStyle(style: .keyboard(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
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
                _ = modifier.applyStyle(style: .link(url), rangeOrWholeString: .range(range))
                self?.updateHighlightedAccessoryView((range, attributedText))
                self?.switchInputs(textView)
                textView.becomeFirstResponder()
                
            case let .changeColorView(_, inputView):
                self?.switchInputs(textView, accessoryView: nil, inputView: inputView)

            case let .changeColor(range, textColor, backgroundColor):
                guard range.length > 0 else { return }
                if let textColor = textColor {
                    _ = modifier.applyStyle(style: .textColor(textColor), rangeOrWholeString: .range(range))
                }
                if let backgroundColor = backgroundColor {
                    _ = modifier.applyStyle(style: .backgroundColor(backgroundColor), rangeOrWholeString: .range(range))
                }
                return
            default: return
            }
        }
    }    
}

// MARK: Attributes and MarkStyles Converter (Move it to MarksPane)
private extension FileNamespace {
    enum ActionsToMarkStyleConverter {
        static func emptyMark(from action: MarksPane.Main.Panes.StylePane.FontStyle.Action) -> TextView.MarkStyle {
            switch action {
            case .bold: return .bold(false)
            case .italic: return .italic(false)
            case .strikethrough: return .strikethrough(false)
            case .keyboard: return .keyboard(false)
            }
        }
        static func textAlignment(from action: MarksPane.Main.Panes.StylePane.Alignment.Action) -> NSTextAlignment {
            switch action {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
}

// MARK: Marks Input View handling
extension FileNamespace {
    private enum ActionToCategoryConverter {
        typealias ContextualMenuAction = TextView.UIKitTextView.ContextualMenu.Action
        typealias Category = MarksPane.Main.Section.Category
        static func asCategory(_ action: ContextualMenuAction) -> Category {
            switch action {
            case .style: return .style
            case .color: return .textColor
            case .background: return .backgroundColor
            }
        }
    }
    func updateMarksInputView(_ tuple: (NSRange, NSTextStorage)) {
        let (range, storage) = tuple
        self.marksToolbarInputView.viewModel.update(range: range, attributedText: storage)
    }
    func updateMarksInputView(_ quadruple: (NSRange, NSTextStorage, UITextView, TextView.UIKitTextView.ContextualMenu.Action)) {
        let (range, storage, textView, action) = quadruple
        self.updateMarksInputView((range, storage, textView))
        self.marksToolbarInputView.viewModel.update(category: ActionToCategoryConverter.asCategory(action))
    }
    func updateMarksInputView(_ triple: (NSRange, NSTextStorage, UITextView)) {
        let (range, storage, textView) = triple
        self.marksToolbarInputView.viewModel.update(range: range, attributedText: storage, alignment: textView.textAlignment)
    }
}

// MARK: Highlighted Accessory view handling
extension FileNamespace {
    func updateHighlightedAccessoryView(_ tuple: (NSRange, NSTextStorage)) {
        let (range, storage) = tuple
        self.highlightedAccessoryView.model.update(range: range, attributedText: storage)
    }
}

// MARK: Input Switching
private extension FileNamespace {
    func switchInputs(_ textView: UITextView,
                      accessoryView: UIView?,
                      inputView: UIView?) {
        self.inputSwitcher.switchInputs(self.defaultKeyboardRect.size,
                                        textView: textView,
                                        accessoryView: accessoryView,
                                        inputView: inputView)
    }
    
    func switchInputs(_ textView: UITextView) {
        self.inputSwitcher.switchInputs(self, textView: textView)
    }
}

// MARK: - UITextViewDelegate

extension TextView.UIKitTextView.Coordinator: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // In the case of frequent pressing of enter
        // we can send multiple split requests to middle
        // from the same block, it will leads to wrong order of blocks in array,
        // adding a delay in UITextView makes impossible to press enter very often
        if text == "\n" && !self.pressingEnterTimeChecker.exceedsTimeInterval() {
            return false
        }
        self.publishToOuterWorld(TextView.UserAction.KeyboardAction.convert(textView, shouldChangeTextIn: range, replacementText: text))
        
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
        /// TODO: Refactor it later.
        return;
        self.switchInputs(textView)
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.inputAccessoryView == nil {
            textView.inputAccessoryView = self.editingToolbarAccessoryView
        }
        self.switchInputs(textView)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textSize = textView.intrinsicContentSize
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        /// TODO: Refactor it later.
        return;
        self.switchInputs(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.intrinsicContentSize
        self.publishToOuterWorld(TextView.UserAction.inputAction(.changeText(textView.attributedText)))
        self.switchInputs(textView)
        guard self.textSize?.height != contentSize.height else { return }
        self.textSize = contentSize
        DispatchQueue.main.async {
            self.textSizeChangeSubject.send(contentSize)
        }
    }
}

// MARK: - Update Text
extension FileNamespace {
    func notifySubscribers(_ payload: TextView.UIKitTextView.TextViewWithPlaceholder.TextStorageEvent.Payload) {
        /// NOTE:
        /// We could remove notification about new attributedText
        /// because we have already notify our subscribers in `textViewDidChange`
        ///
        
        /// We don't need any dispatching, because we are receiving values on different than .main queue.
        self.attributedTextSubject.send(payload.attributedText)
        self.textAlignmentSubject.send(payload.textAlignment)
    }
}

// MARK: - InnerTextView.Coordinator / UIGestureRecognizerDelegate

extension TextView.UIKitTextView.Coordinator: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func tap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        func message(_ state: UIGestureRecognizer.State) -> String {
            switch state {
            case .possible: return ".possible"
            case .began: return ".began"
            case .changed: return ".changed"
            case .ended: return ".ended|.recognized" // Same sa .recognized
            case .cancelled: return ".cancelled"
            case .failed: return ".failed"
            @unknown default: return "TheUnknown"
            }
        }
        switch gestureRecognizer.state {
        case .recognized: gestureRecognizer.view?.becomeFirstResponder()
        default: break
        }
        
        Logger.create(.textViewUIKitTextViewCoordinator).debug("\(self) tap: \(message(gestureRecognizer.state))")
    }
}


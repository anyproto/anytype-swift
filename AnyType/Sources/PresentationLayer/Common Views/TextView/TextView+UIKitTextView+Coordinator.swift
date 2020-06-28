//
//  TextView+UIKitTextView+Coordinator.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os

private extension Logging.Categories {
    static let textViewUIKitTextViewCoordinator: Self = "TextView.UIKitTextView.Coordinator"
}

extension TextView.UIKitTextView {
    class Coordinator: NSObject {
        // MARK: Aliases
        typealias TheTextView = TextView.UIKitTextView
        typealias HighlightedAccessoryView = TextView.HighlightedToolbar.AccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView
        typealias ActionsToolbarAccessoryView = TextView.ActionsToolbar.AccessoryView
        typealias MarksToolbarInputView = MarksPane.Main.ViewModelHolder

        // MARK: Variables
        @Published var text: String? = nil
        @Published var attributedText: NSAttributedString? = nil
        @Published var textAlignment: NSTextAlignment? = nil
        
        private weak var userInteractionDelegate: TextViewUserInteractionProtocol?
        func configure(_ delegate: TextViewUserInteractionProtocol?) -> Self {
            self.userInteractionDelegate = delegate
            return self
        }
        
        /// TextStorage Subscription
        private var textStorageSubscription: AnyCancellable?
        
        /// ContextualMenu Subscription
        private var contextualMenuSubscription: AnyCancellable?
        
        /// HighlightedAccessoryView
        private lazy var highlightedAccessoryView: HighlightedAccessoryView = .init()
        private var highlightedMarkStyleHandler: AnyCancellable?
        
        /// Whole mark style handler
        private var wholeMarkStyleHandler: AnyCancellable?
        
        /// BlocksAccessoryView
        private lazy var blocksAccessoryView: BlockToolbarAccesoryView = .init()
        private var blocksAccessoryViewHandler: AnyCancellable?
        private var blocksUserActionsHandler: AnyCancellable?
        
        /// ActionsAccessoryView
        private lazy var actionsToolbarAccessoryView: ActionsToolbarAccessoryView = .init()
        private var actionsToolbarAccessoryViewHandler: AnyCancellable?
        private var actionsToolbarUserActionsHandler: AnyCancellable?
        
        /// MarksInputView
        private lazy var marksToolbarInputView: MarksToolbarInputView = .init()
        private var marksToolbarHandler: AnyCancellable? // Hm... we need what?
        /// We need handler which connects contextual menu action and will handle "changing" of value in marksToolbar and also trigger it appearance.
        /// Also, we need handler which connects marks processing.
        /// And also, we need a handler which updates current state of marks ( like updateHighlightingMenu )
        
        
        private var keyboardObserverHandler: AnyCancellable?
        private var defaultKeyboardRect: CGRect = .zero
        
        // MARK: - Initiazliation
        override init() {
            super.init()
            self.setup()
        }
        
        func setup() {
            self.configureKeyboardNotificationsListening()
        }
    }
}

extension TextView.UIKitTextView.Coordinator {
    func configureKeyboardNotificationsListening() {
        self.keyboardObserverHandler = KeyboardObserver.default.$keyboardInformation.map(\.keyboardRect).filter({
            [weak self] value in
            value != .zero && self?.defaultKeyboardRect == .zero
        }).sink{ [weak self] value in self?.defaultKeyboardRect = value }
    }
}

// MARK: InnerTextView.Coordinator / Publishers
extension TextView.UIKitTextView.Coordinator {
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
    
    // MARK: - Publishers / Actions Toolbar
    func configureActionsToolbarHandler(_ view: UITextView) {
        self.actionsToolbarAccessoryViewHandler = Publishers.CombineLatest(Just(view), self.actionsToolbarAccessoryView.model.$userAction).sink(receiveValue: { [weak self] (value) in
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
        self.actionsToolbarUserActionsHandler = self.actionsToolbarAccessoryView.model.allInOnePublisher.sink { [weak self] value in
            // now tell outer world that we are ready to process actions.
            // ...
            self?.publishToOuterWorld(value)
        }
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
    
    // MARK: - Publishers / Highlighted Toolbar
    func updateWholeMarkStyle(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        let (textView, value) = (view, wholeMarkStyleKeeper.value)
        let attributedText = textView.textStorage
        let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
        if let style = modifier.getMarkStyle(style: .strikethrough(value.strikethrough), at: .whole(true)), style != .strikethrough(value.strikethrough) {
            _ = modifier.applyStyle(style: .strikethrough(value.strikethrough), rangeOrWholeString: .whole(true))
        }
        if let color = value.textColor, let style = modifier.getMarkStyle(style: .textColor(color), at: .whole(true)), style != .textColor(color) {
            _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .whole(true))
        }
    }
    func configureWholeMarkStylePublisher(_ view: UITextView, wholeMarkStyleKeeper: TextView.MarkStyleKeeper) {
        self.wholeMarkStyleHandler = Publishers.CombineLatest(Just(view), wholeMarkStyleKeeper.$value).sink { (textView, value) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            if let style = modifier.getMarkStyle(style: .strikethrough(value.strikethrough), at: .whole(true)), style != .strikethrough(value.strikethrough) {
                _ = modifier.applyStyle(style: .strikethrough(value.strikethrough), rangeOrWholeString: .whole(true))
            }
            if let color = value.textColor, let style = modifier.getMarkStyle(style: .textColor(color), at: .whole(true)), style != .textColor(color) {
                _ = modifier.applyStyle(style: .textColor(color), rangeOrWholeString: .whole(true))
            }
        }
    }
        
    func configureMarkStylePublisher(_ view: UITextView) {
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { [weak self] (textView, action) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            
            let logger = Logging.createLogger(category: .textViewUIKitTextViewCoordinator)
            os_log(.debug, log: logger, "configureMarkStylePublisher %@", "\(action)")
            
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
    
    func configureMarksPanePublisher(_ view: UITextView) {
        self.marksToolbarHandler = Publishers.CombineLatest(Just(view), self.marksToolbarInputView.viewModel.userAction).sink { [weak self] (value) in
            let (textView, action) = value
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            
            let logger = Logging.createLogger(category: .textViewUIKitTextViewCoordinator)
            os_log(.debug, log: logger, "MarksPane action %@", "\(action)")
            
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
}

// MARK: Attributes and MarkStyles Converter (Move it to MarksPane)
extension TextView.UIKitTextView.Coordinator {
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


// MARK: ContextualMenuHandling
extension TextView.UIKitTextView.Coordinator {
    // TODO: Put textView into it.
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

// MARK: Marks Input View handling
extension TextView.UIKitTextView.Coordinator {
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
        self.updateMarksInputView((quadruple.0, quadruple.1, quadruple.2))
        self.marksToolbarInputView.viewModel.update(category: ActionToCategoryConverter.asCategory(quadruple.3))
    }
    func updateMarksInputView(_ triple: (NSRange, NSTextStorage, UITextView)) {
        self.marksToolbarInputView.viewModel.update(range: triple.0, attributedText: triple.1, alignment: triple.2.textAlignment)
    }
}

// MARK: Highlighted Accessory view handling
extension TextView.UIKitTextView.Coordinator {
    func updateHighlightedAccessoryView(_ tuple: (NSRange, NSTextStorage)) {
        let (range, storage) = tuple
        self.highlightedAccessoryView.model.update(range: range, attributedText: storage)
    }
}

// MARK: Input Switcher
private extension TextView.UIKitTextView.Coordinator {
    class InputSwitcher {
        struct Triplet {
            var shouldAnimate: Bool
            var accessoryView: UIView?
            var inputView: UIView?
        }
        typealias Coordinator = TextView.UIKitTextView.Coordinator
        
        /// Switch inputs based on textView, accessoryView and inputView.
        /// Do not override this method until you rewrite everything on top of one input view and one accessory view.
        ///
        /// - Parameters:
        ///   - inputViewKeyboardSize: Size of keyboard input view. ( actually, default keyboard size ).
        ///   - textView: textView which would reload input views.
        ///   - accessoryView: accessory view which will be taken in account in switching
        ///   - inputView: input view which will be taken in account in switching
        class func switchInputs(_ inputViewKeyboardSize: CGSize, textView: UITextView, accessoryView: UIView?, inputView: UIView?) {
            if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
                textView.inputView = nil
                textView.reloadInputViews()
                return
            }
            else {
                let size = inputViewKeyboardSize
                inputView?.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
                textView.inputView = inputView
                textView.reloadInputViews()
            }
            
            if let accessoryView = accessoryView {
                textView.inputAccessoryView = accessoryView
                textView.reloadInputViews()
            }
        }
        
        // MARK: Subclassing
        /// Choose which keyboard you need to show.
        /// - Parameters:
        ///   - coordinator: current coordinator
        ///   - textView: current text view
        ///   - selectionLength: length of selection
        ///   - accessoryView: current accessory view.
        ///   - inputView: current input view.
        /// - Returns: A triplet of flag, accessory view and input view. Flag equal `shouldAnimate` and indicates if we need animation in switching.
        class func variantsFromState(_ coordinator: Coordinator, textView: UITextView, selectionLength: Int, accessoryView: UIView?, inputView: UIView?) -> Triplet {
            .init(shouldAnimate: false, accessoryView: nil, inputView: nil)
        }
        
        /// Actually, switch input views.
        /// - Parameters:
        ///   - coordinator: Coordinator which will provide data to correct views.
        ///   - textView: textView which will handle input views.
        class func switchInputs(_ coordinator: Coordinator, textView: UITextView) {
            let triplet = self.variantsFromState(coordinator, textView: textView, selectionLength: textView.selectedRange.length, accessoryView: textView.inputAccessoryView, inputView: textView.inputView)
            
            let (shouldAnimate, accessoryView, inputView) = (triplet.shouldAnimate, triplet.accessoryView, triplet.inputView)
            
            if shouldAnimate {
                textView.inputAccessoryView = accessoryView
                textView.inputView = inputView
                textView.reloadInputViews()
            }
            
            self.didSwitchViews(coordinator, textView: textView)
        }
        
        /// When we switch views, we could prepare our views.
        /// - Parameters:
        ///   - coordinator: current coordinator
        ///   - textView: text view that switch views.
        class func didSwitchViews(_ coordinator: Coordinator, textView: UITextView) {}
    }
    
    // MARK: Old switcher
    class BlocksAndHighlightingInputSwitcher: InputSwitcher {
        override class func variantsFromState(_ coordinator: Coordinator, textView: UITextView, selectionLength: Int, accessoryView: UIView?, inputView: UIView?) -> Triplet {
            switch (selectionLength, accessoryView, inputView) {
            // Length == 0, => set blocks toolbar and restore default keyboard.
            case (0, _, _): return .init(shouldAnimate: true, accessoryView: coordinator.blocksAccessoryView, inputView: nil)
            // Length != 0 and is BlockToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
            case (_, is Coordinator.BlockToolbarAccesoryView, _): return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
            // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
            case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
            // Otherwise, we need to keep accessory view and keyboard.
            default: return .init(shouldAnimate: false, accessoryView: accessoryView, inputView: inputView)
            }
        }
        override class func didSwitchViews(_ coordinator: TextView.UIKitTextView.Coordinator.InputSwitcher.Coordinator, textView: UITextView) {
            if (textView.inputAccessoryView is Coordinator.HighlightedAccessoryView) {
                let range = textView.selectedRange
                let attributedText = textView.textStorage
                coordinator.updateHighlightedAccessoryView((range, attributedText))
            }
        }
    }
    
    // MARK: Actions and Highlighting switcher
    class ActionsAndHighlightingInputSwitcher: BlocksAndHighlightingInputSwitcher {
        override class func variantsFromState(_ coordinator: Coordinator, textView: UITextView, selectionLength: Int, accessoryView: UIView?, inputView: UIView?) -> Triplet {
            switch (selectionLength, accessoryView, inputView) {
            // Length == 0, => set actions toolbar and restore default keyboard.
            case (0, _, _): return .init(shouldAnimate: true, accessoryView: coordinator.actionsToolbarAccessoryView, inputView: nil)
            // Length != 0 and is ActionsToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
            case (_, is Coordinator.ActionsToolbarAccessoryView, _): return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
            // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
            case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
            // Otherwise, we need to keep accessory view and keyboard.
            default: return .init(shouldAnimate: false, accessoryView: accessoryView, inputView: inputView)
            }
        }
    }
    
    // MARK: Actions and MarksPane switcher
    class ActionsAndMarksPaneInputSwitcher: InputSwitcher {
        override class func switchInputs(_ inputViewKeyboardSize: CGSize, textView: UITextView, accessoryView: UIView?, inputView: UIView?) {
            if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
                return
            }
            else {
                let size = inputViewKeyboardSize
                inputView?.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
                textView.inputView = inputView
                textView.reloadInputViews()
            }
            
            if let accessoryView = accessoryView {
                textView.inputAccessoryView = accessoryView
                textView.reloadInputViews()
            }
        }

        override class func variantsFromState(_ coordinator: Coordinator, textView: UITextView, selectionLength: Int, accessoryView: UIView?, inputView: UIView?) -> Triplet {
            switch (selectionLength, accessoryView, inputView) {
            // Length == 0, => set actions toolbar and restore default keyboard.
            case (0, _, _): return .init(shouldAnimate: true, accessoryView: coordinator.actionsToolbarAccessoryView, inputView: nil)
            // Length != 0 and is ActionsToolbarAccessoryView => set marks pane input view and restore default accessory view (?).
            case (_, is Coordinator.ActionsToolbarAccessoryView, _): return .init(shouldAnimate: true, accessoryView: nil, inputView: coordinator.marksToolbarInputView.view)
            // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
            case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return .init(shouldAnimate: true, accessoryView: coordinator.highlightedAccessoryView, inputView: nil)
            // Otherwise, we need to keep accessory view and keyboard.
            default: return .init(shouldAnimate: false, accessoryView: accessoryView, inputView: inputView)
            }
        }
        override class func didSwitchViews(_ coordinator: TextView.UIKitTextView.Coordinator.InputSwitcher.Coordinator, textView: UITextView) {
            if (textView.inputView == coordinator.marksToolbarInputView.view) {
                let range = textView.selectedRange
                let attributedText = textView.textStorage
                coordinator.updateMarksInputView((range, attributedText, textView))
            }
        }
        
        override class func switchInputs(_ coordinator: TextView.UIKitTextView.Coordinator.InputSwitcher.Coordinator, textView: UITextView) {
            let triplet = self.variantsFromState(coordinator, textView: textView, selectionLength: textView.selectedRange.length, accessoryView: textView.inputAccessoryView, inputView: textView.inputView)
            
            let (_, accessoryView, inputView) = (triplet.shouldAnimate, triplet.accessoryView, triplet.inputView)
            
            self.switchInputs(coordinator.defaultKeyboardRect.size, textView: textView, accessoryView: accessoryView, inputView: inputView)
            
            self.didSwitchViews(coordinator, textView: textView)

        }
    }
}

// MARK: Input Switching
extension TextView.UIKitTextView.Coordinator {
    private typealias Switcher = ActionsAndMarksPaneInputSwitcher
    func switchInputs(_ textView: UITextView, accessoryView: UIView?, inputView: UIView?) {
        Switcher.switchInputs(self.defaultKeyboardRect.size, textView: textView, accessoryView: accessoryView, inputView: inputView)
    }
    
    func switchInputs(_ textView: UITextView) {
        Switcher.switchInputs(self, textView: textView)
    }
}

// MARK: InnerTextView.Coordinator / UITextViewDelegate
extension TextView.UIKitTextView.Coordinator: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.publishToOuterWorld(TextView.UserAction.KeyboardAction.convert(textView, shouldChangeTextIn: range, replacementText: text))
        if text == "\n" {
            // we should return false and perform update by ourselves.
            switch (textView.text, range) {
            case (_, .init(location: 0, length: 0)): textView.text = ""
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
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.switchInputs(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.switchInputs(textView)
    }
        
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            // TODO: Add text (?) publisher
            self.text = textView.text
            self.attributedText = textView.attributedText
            
            /// Don't delete this code until we have stable solution for textView attributedText updates.
            /// Maybe we will discard current `@Publsihed` solution.
            ///
//            self.publishToOuterWorld(TextView.UserAction.inputAction(.changeText(textView.text)))
        }
    }
}

// MARK: - Update Text
extension TextView.UIKitTextView.Coordinator {
    /// NOTE:
    /// As soon as we notify ourselves about all updates in textStorage, we have side effects.
    /// For example,
    /// When you invoke `textStorage.setAttributedString` somewhere, this publisher gets notification about change.
    /// That means, `notifySubscribers` will invoke and we get notification about change in outerWorld.
    ///
    /// Nothing is wrogn here, but...
    /// When you set `NSAttributedString` at first time, you get additional call to middleware.
    ///
    /// We could add additional check if `attributedText is nil` and catch "setupAtFirstTime" event.
    ///
    func configured(textStorageStream: AnyPublisher<TextView.UIKitTextView.TextViewWithPlaceholder.TextStorageEvent, Never>) -> Self {
        self.textStorageSubscription = textStorageStream.sink(receiveValue: { [weak self] (value) in
            switch value {
            case .willProcessEditing(_): return
            case let .didProcessEditing(payload): self?.notifySubscribers(payload)
            }
        })
        return self
    }
    private func notifySubscribers(_ payload: TextView.UIKitTextView.TextViewWithPlaceholder.TextStorageEvent.Payload) {
        self.attributedText = payload.attributedText
        self.textAlignment = payload.textAlignment
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
        
        let logger = Logging.createLogger(category: .textViewUIKitTextViewCoordinator)
        os_log(.debug, log: logger, "%s tap: %s", "\(self)", "\(message(gestureRecognizer.state))")
    }
}


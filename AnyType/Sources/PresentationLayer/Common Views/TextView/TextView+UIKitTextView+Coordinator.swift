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

extension TextView.UIKitTextView {
    class Coordinator: NSObject {
        // MARK: Aliases
        typealias TheTextView = TextView.UIKitTextView
        typealias HighlightedAccessoryView = TextView.HighlightedToolbar.AccessoryView
        typealias BlockToolbarAccesoryView = TextView.BlockToolbar.AccessoryView

        // MARK: Variables
        @Published var text: String = ""
        private weak var userInteractionDelegate: TextViewUserInteractionProtocol?
        func configure(_ delegate: TextViewUserInteractionProtocol?) -> Self {
            self.userInteractionDelegate = delegate
            return self
        }
        
        private lazy var highlightedAccessoryView: HighlightedAccessoryView = .init()
        private var highlightedAccessoryViewHandler: (((NSRange, NSTextStorage)) -> ())?
        
        private var highlightedMarkStyleHandler: AnyCancellable?
        private var wholeMarkStyleHandler: AnyCancellable?
        
        private lazy var blocksAccessoryView: BlockToolbarAccesoryView = .init()
        private var blocksAccessoryViewHandler: AnyCancellable?
        private var blocksUserActionsHandler: AnyCancellable?
        
        private var keyboardObserverHandler: AnyCancellable?
        private var defaultKeyboardRect: CGRect = .zero
        
        // MARK: - Initiazliation
        override init() {
            super.init()
            self.setup()
        }
        
        func setup() {
            self.configureInnerAccessoryViewHandler()
            self.configureKeyboardNotificationsListening()
        }
    }
}

extension TextView.UIKitTextView.Coordinator {
    func configureKeyboardNotificationsListening() {
        self.keyboardObserverHandler =
            Publishers.CombineLatest(Just(self), KeyboardObserver.default.$keyboardInformation).filter{$0.0.defaultKeyboardRect == .zero && $0.1.keyboardRect != .zero}.sink { value in
            let (left, right) = value
            print(" left: \(left.defaultKeyboardRect) \n right: \(right.keyboardRect)")
            left.defaultKeyboardRect = right.keyboardRect
        }
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
    
    // MARK: - Publishers / Blocks Toolbar
    func configureBlocksToolbarHandler(_ view: UITextView) {
        self.blocksAccessoryViewHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.$userAction).sink(receiveValue: { (value) in
            let (textView, action) = value
            
            guard action.action != .keyboardDismiss else {
                textView.endEditing(false)
                return
            }
            
            self.switchInputs(textView, accessoryView: nil, inputView: action.view)
        })
        
        // TODO: Add other user interaction publishers.
        // 1. Add hook that will send this data to delegate.
        // 2. Add delegate that will take UserAction like delegate?.onUserAction(UserAction)
        // 3. Add another delegate that will "wraps" UserAction with information about block ( first delegate IS a observableModel or even just ObservableObject or @binding... )
        // 4. Second delegate is a documentViewModel ( so, it needs information about block if available.. )
        // 5. Add hook to receive user key inputs and context of current text View. ( enter may behave different ).
        // 6. Add hook that will catch marks styles. ( special convert for links and colors )
        self.blocksUserActionsHandler = Publishers.CombineLatest(Just(view), self.blocksAccessoryView.model.allInOnePublisher).sink { [weak self] value in
            let (_, action) = value
            // now tell outer world that we are ready to process actions.
            // ...
            self?.publishToOuterWorld(action)
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
    
    func configureInnerAccessoryViewHandler() {
        self.highlightedAccessoryViewHandler = { [weak self] (pair) in
            let (range, text) = pair
            self?.highlightedAccessoryView.model.update(range: range, attributedText: text)
        }
    }
    
    func configureMarkStylePublisher(_ view: UITextView) {
        self.highlightedMarkStyleHandler = Publishers.CombineLatest(Just(view), self.highlightedAccessoryView.model.$userAction).sink { (textView, action) in
            let attributedText = textView.textStorage
            let modifier = TextView.MarkStyleModifier(attributedText: attributedText).update(by: textView)
            print("\(action)")
            switch action {
            case .keyboardDismiss: textView.endEditing(false)
            case let .bold(range):
                if let style = modifier.getMarkStyle(style: .bold(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))

            case let .italic(range):
                if let style = modifier.getMarkStyle(style: .italic(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
                
            case let .strikethrough(range):
                if let style = modifier.getMarkStyle(style: .strikethrough(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
                
            case let .keyboard(range):
                if let style = modifier.getMarkStyle(style: .keyboard(false), at: .range(range)) {
                    _ = modifier.applyStyle(style: style.opposite(), rangeOrWholeString: .range(range))
                }
                self.highlightedAccessoryViewHandler?((range, attributedText))
                
            case let .linkView(range, builder):
                let style = modifier.getMarkStyle(style: .link(nil), at: .range(range))
                let string = attributedText.attributedSubstring(from: range).string
                let view = builder(string, style.flatMap({
                    switch $0 {
                    case let .link(link): return link
                    default: return nil
                    }
                }))
                self.switchInputs(textView, accessoryView: view, inputView: nil)
                // we should apply selection attributes to indicate place where link will be applied.

            case let .link(range, url):
                guard range.length > 0 else { return }
                _ = modifier.applyStyle(style: .link(url), rangeOrWholeString: .range(range))
                self.highlightedAccessoryViewHandler?((range, attributedText))
                self.switchInputs(textView)
                textView.becomeFirstResponder()
                
            case let .changeColorView(_, inputView):
                self.switchInputs(textView, accessoryView: nil, inputView: inputView)

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

// MARK: InnerTextView.Coordinator / UITextViewDelegate
extension TextView.UIKitTextView.Coordinator: UITextViewDelegate {
    // MARK: Input Switching
    func switchInputs(_ textView: UITextView, accessoryView: UIView?, inputView: UIView?) {
        if let currentView = textView.inputView, let nextView = inputView, type(of: currentView) == type(of: nextView) {
            textView.inputView = nil
            textView.reloadInputViews()
            return
        }
        else {
            inputView?.frame = .init(x: 0, y: 0, width: self.defaultKeyboardRect.size.width, height: self.defaultKeyboardRect.size.height)
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        if let accessoryView = accessoryView {
            textView.inputAccessoryView = accessoryView
            textView.reloadInputViews()
        }
    }
    
    func switchInputs(_ textView: UITextView) {
        func switchInputs(_ length: Int, accessoryView: UIView?, inputView: UIView?) -> (Bool, UIView?, UIView?) {
            switch (length, accessoryView, inputView) {
            // Length == 0, => set blocks toolbar and restore default keyboard.
            case (0, _, _): return (true, self.blocksAccessoryView, nil)
            // Length != 0 and is BlockToolbarAccessoryView => set highlighted accessory view and restore default keyboard.
            case (_, is BlockToolbarAccesoryView, _): return (true, self.highlightedAccessoryView, nil)
            // Length != 0 and is InputLink.ContainerView when textView.isFirstResponder => set highlighted accessory view and restore default keyboard.
            case (_, is TextView.HighlightedToolbar.InputLink.ContainerView, _) where textView.isFirstResponder: return (true, self.highlightedAccessoryView, nil)
            // Otherwise, we need to keep accessory view and keyboard.
            default: return (false, accessoryView, inputView)
            }
        }
                
        let (shouldAnimate, accessoryView, inputView) = switchInputs(textView.selectedRange.length, accessoryView: textView.inputAccessoryView, inputView: textView.inputView)
        
        if shouldAnimate {
            textView.inputAccessoryView = accessoryView
            textView.inputView = inputView
            textView.reloadInputViews()
        }
        
        if (textView.inputAccessoryView is HighlightedAccessoryView) {
            let range = textView.selectedRange
            let attributedText = textView.textStorage
            self.highlightedAccessoryViewHandler?((range, attributedText))
        }
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.publishToOuterWorld(TextView.UserAction.KeyboardAction.convert(textView, shouldChangeTextIn: range, replacementText: text))
        if text == "\n" {
            // we should return false and perform update by ourselves.
            switch (textView.text, range) {
            case (_, .init(location: 1, length: 0)): textView.text = ""
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
//            self.publishToOuterWorld(TextView.UserAction.inputAction(.changeText(textView.text)))
        }
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
        print("tap \(message(gestureRecognizer.state))")
    }
}

//MARK: TextViewUserInteractionProtocol
extension TextView.UIKitTextView.Coordinator: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: TextView.UserAction) {
        print("I receive! \(action)")
    }
}


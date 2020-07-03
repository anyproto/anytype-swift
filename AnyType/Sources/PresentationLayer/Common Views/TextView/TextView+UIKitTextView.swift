//
//  TextView+UIKitTextView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

extension TextView {
    class UIKitTextView: UIView {
        // MARK: Combine
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Options ( From Developers To Managers ONLY )
        struct Options {
            /// Well, we still don't have correct handling of input data.
            /// We should assure ourselves, that our data will be handled correctly.
            /// Read about usage of this flag below.
            var liveUpdateAvailable: Bool
        }
        private var options: Options = .init(liveUpdateAvailable: false)
        
        // MARK: ViewModel
        weak var model: ViewModel?
        
        // MARK: Resources
        struct Resources {}
        
        // MARK: TODO: Remove
        var getTextView: UITextView? {
            return textView
        }
                
        func update(placeholder: Placeholder) {
            // set placeholder to view.
            if let view = self.textView as? TextViewWithPlaceholder {
                view.update(placeholder: placeholder.placeholder)
            }
        }
        
        // MARK: Outlets
        private var contentView: UIView!
        private var textView: UITextView!
        
        // MARK: Configuration
        func configured(_ resources: Resources) -> Self {
            return self
        }
        
        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupInteractions()
        }
        
        // MARK: Setup Interactions
        private func setupInteractions() {
            
            /// TODO: Fix it.
            /// It will be correct after we get it right after Marks PR.
            ///
            /// We could store this into subscription `IF ONLY` we assure ourselves, that text in this field will be handled correctly.
            ///
            if self.options.liveUpdateAvailable {
                self.model?.$update.sink(receiveValue: {[weak self] value in self?.onUpdate(value)}).store(in: &self.subscriptions)
            }
            else {
                /// We don't store this subscription _intentionally_.
                _ = self.model?.$update.sink(receiveValue: {[weak self] value in self?.onUpdate(value)})
            }
            
            /// TODO: Fix it and read comments above.
            /// This is intentional update publisher.
            /// It is one-fire event and it is necessary only when view exists.
            /// It doesn't store value.
            self.model?.intentionalUpdatePublisher.sink(receiveValue: { [weak self] (value) in
                self?.onUpdate(value)
            }).store(in: &self.subscriptions)
            
            // Set Focus
            self.model?.$setFocus.safelyUnwrapOptionals().sink(receiveValue: { [weak self] (value) in
                self?.setFocus(value)
            }).store(in: &self.subscriptions)
            
            // Resign first responder
            self.model?.shouldResignFirstResponderPublisher.sink(receiveValue: { [weak self] (value) in
                self?.textView.resignFirstResponder()
            }).store(in: &self.subscriptions)
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            guard let model = self.model else { return }
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.textView = {
                let view = model.createInnerView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
                        
            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView.addSubview(self.textView)
            self.addSubview(self.contentView)
        }
        
        // MARK: Layout
        private func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.textView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
        }
        
        override var intrinsicContentSize: CGSize {
            return .zero
        }
        
    }
}

// MARK: Updates
extension TextView.UIKitTextView {
    func onUpdate(_ update: TextView.UIKitTextView.ViewModel.Update) {
        switch update {
        case .unknown: return
        case let .text(value):
            // NOTE: Read these cases carefully.
            // 1. self.textView.textStorage.length == 0.
            // This case is simple. We should take _typingAttributes_ from textView and configure new attributed string.
            // 2. self.textView.textStorage.length != 0.
            // We should _replace_ text in range, however, if we don't check that our string is empty, we will configure incorrect attributes.
            // There is no way to set attributes for text, becasue it is inherited from attributes that are assigned to first character, that will be replaced.
            if self.textView.textStorage.length == 0 {
                let text = NSAttributedString(string: value, attributes: self.textView.typingAttributes)
                self.textView.textStorage.setAttributedString(text)
            }
            else {
                self.textView.textStorage.replaceCharacters(in: .init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        case let .attributedText(value):
            let text = NSMutableAttributedString.init(attributedString: value)

            /// TODO: Poem "Do we need to add font?"
            ///
            /// Hm...
            /// Actually, don't know. Should think about this problem ( when and where ) we should set font of attributed string.
            ///
            /// The main problem is that we should use `.font` to apply attributes to `NSAttributedString`.
            ///
            /// Example code below.
            ///
            /// let font: UIFont = self.textView.typingAttributes[.foregroundColor] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
            /// text.addAttributes([.font : font], range: .init(location: 0, length: text.length))
            ///
            if self.textView.textStorage.length == 0 {
                self.textView.textStorage.setAttributedString(text)
            }
            else {
                /// Actually, we should add more logic here.
                /// If it is happenning, that means, that some event occurs when user typing or when page is already open.
                /// It may be a blockSetText event from external user.
                /// Lets keep it simple for now.
                ///
                self.textView.textStorage.setAttributedString(text)
                // self.textView.textStorage.replaceCharacters(in: .init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        case let .auxiliary(value):
            let textAlignment = value.textAlignment
            self.textView.textAlignment = textAlignment
            
        case let .payload(value):
            self.onUpdate(.attributedText(value.attributedString))
            
            /// We changed order, because textAlignment is a part of NSAttributedString.
            /// That means, we have to move processing of textAlignment to MarksStyle.
            /// It is a part of NSAttributedString attributes ( `NSParagraphStyle.alignment` ).
            ///
            self.onUpdate(.auxiliary(value.auxiliary))
        }
    }
}

// MARK: Focus
extension TextView.UIKitTextView {
    private func setFocus(_ value: ViewModel.Focus.Position) {
        let position = value
        switch position {
        case .unknown: break
        case .beginning:
            if let textView = self.textView {
                let position = textView.beginningOfDocument
                let range = textView.textRange(from: position, to: position)
                textView.selectedTextRange = range
            }
        case .end:
            if let textView = self.textView {
                let position = textView.endOfDocument
                let range = textView.textRange(from: position, to: position)
                textView.selectedTextRange = range
            }
        case let .at(value):
            if let textView = self.textView {
                // check that we can set it.
                let length = self.textView.textStorage.length
                let zero = 0
                let newValue = min(max(value, zero), length)
                switch newValue {
                case zero: self.setFocus(.beginning)
                case length: self.setFocus(.end)
                default:
                    let beginning = textView.beginningOfDocument
                    if let position = textView.position(from: beginning, offset: newValue) {
                        let range = textView.textRange(from: position, to: position)
                        textView.selectedTextRange = range
                    }
                }
            }
        }
        self.textView?.becomeFirstResponder()
    }
    func setFocus(_ value: ViewModel.Focus) {
        guard let position = value.position else { return }
        self.setFocus(position)
        switch position {
        case .unknown: break
        default:
            /// NOTES:
            /// We must assure ourselves, that we really set view as firstResponder.
            /// Otherwise, we should set first responder when view will go into layout cycle.
            ///
            if self.textView.isFirstResponder {
            value.completion(true)
            }
//            break
        }
    }
}

// MARK: Configuration
extension TextView.UIKitTextView {
    func configured(_ options: Options) -> Self {
        self.options = options
        return self
    }
    
    func configured(_ model: ViewModel?) -> Self {
        self.model = model
        self.setup()
        
        return self
    }
    
    func configured(placeholder: Placeholder) -> Self {
        self.update(placeholder: placeholder)
        return self
    }
}

// MARK: Placeholder
extension TextView.UIKitTextView {
    struct Placeholder {
        var text: String?
        var attributedText: NSAttributedString?
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        fileprivate var placeholder: NSAttributedString {
            if let result = attributedText {
                return result
            }
            else {
                return NSMutableAttributedString.init(string: self.text ?? "", attributes: attributes)
            }
        }
        
        mutating func configured(text: String?) -> Self {
            self.text = text
            return self
        }
        
        mutating func configured(attributedText: NSAttributedString?) -> Self {
            self.attributedText = attributedText
            return self
        }
        
        mutating func configured(attributes: [NSAttributedString.Key: Any] = [:]) -> Self {
            self.attributes = attributes
            return self
        }
    }
}

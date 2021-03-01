//
//  TextView+UIKitTextView+TextView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os

fileprivate typealias Namespace = TextView.UIKitTextView

private extension Logging.Categories {
    static let textViewUIKitTextView: Self = "TextView.UIKitTextView"
}

extension Namespace {
    enum ContextualMenu {}
}

extension Namespace.ContextualMenu {
    enum Action {
        case style
        case color
        case background
    }
    enum Resources {
        enum Title {
            static func title(for action: Action) -> String {
                switch action {
                case .style: return "Style"
                case .color: return "Color"
                case .background: return "Background"
                }
            }
        }
    }
}

// MARK: - TextStorageEvent
extension Namespace.TextViewWithPlaceholder {
    enum TextStorageEvent {
        struct Payload {
            var attributedText: NSAttributedString
            var textAlignment: NSTextAlignment
        }
        case willProcessEditing(Payload)
        case didProcessEditing(Payload)
    }
}

// MARK: - TextView
extension Namespace {
    class TextViewWithPlaceholder: UITextView {
        
        weak var coordinator: TextView.UIKitTextView.Coordinator?
        
        // MARK: Publishers
        private var textStorageEventsSubject: PassthroughSubject<TextStorageEvent, Never> = .init()
        private(set) var textStorageEventsPublisher: AnyPublisher<TextStorageEvent, Never> = .empty()
        
        private var contextualMenuSubject: PassthroughSubject<ContextualMenu.Action, Never> = .init()
        private(set) var contextualMenuPublisher: AnyPublisher<ContextualMenu.Action, Never> = .empty()
        
        private var resignFirstResponderSubject: PassthroughSubject<Void, Never> = .init()
        private(set) var resignFirstResponderPublisher: AnyPublisher<Void, Never> = .empty()
        
        private var firstResponderChangeSubject: PassthroughSubject<ViewModel.FirstResponder.Change, Never> = .init()
        private(set) var firstResponderChangePublisher: AnyPublisher<ViewModel.FirstResponder.Change, Never> = .empty()
        
        // MARK: Variables
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Views
        private lazy var placeholderLabel: UILabel = {
            let label: UILabel = .init()
            label.textColor = self.textColor
            label.font = self.font
            label.textAlignment = self.textAlignment
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private var placeholderConstraints: [NSLayoutConstraint] = []
        
        
        override var textContainerInset: UIEdgeInsets {
            didSet {
                self.updatePlaceholderLayout()
            }
        }
        
        override var typingAttributes: [NSAttributedString.Key : Any] {
            didSet {
                guard let font = typingAttributes[.font] as? UIFont else { return }
                self.placeholderLabel.font = font
            }
        }

        // MARK: Initialization
        override init(frame: CGRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        // MARK: Setup
        private func setup() {
            self.setupPublishers()
            self.setupUIElements()
            self.updatePlaceholderLayout()
            self.setupMenu()
        }
        
        private func setupUIElements() {
            self.textStorage.delegate = self
            self.addSubview(self.placeholderLabel)
        }
                
        // MARK: Add Layout
        private func updatePlaceholderLayout() {
            let view = self.placeholderLabel
            if let superview = view.superview {
                let insets = self.textContainerInset
                let lineFragmentPadding = self.textContainer.lineFragmentPadding
                
                if !self.placeholderConstraints.isEmpty {
                    self.removeConstraints(self.placeholderConstraints)
                }
                
                self.placeholderConstraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left + lineFragmentPadding),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(insets.right + lineFragmentPadding)),
                    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
                ]
                
                NSLayoutConstraint.activate(self.placeholderConstraints)
            }
        }
        
        func setupPublishers() {
            /// Hm... Maybe it is not good idea to even send updates.
            /// Actually, we only need to dispatch on correct queue?
            /// Do we?
            /// Maybe we need some private queue (?)
            self.textStorageEventsPublisher = self.textStorageEventsSubject
//                .subscribe(on: QueueStorage.updatesQueue)
//                .receive(on: QueueStorage.updatesQueue)
                //.debounce(for: .seconds(1), scheduler: DispatchQueue.global())
                .eraseToAnyPublisher()
            /// TODO: Measure.
            /// We don't care about text anymore. We use debounce technique to sync document.
            /// For that, we need only access to parts of textView.
            /// For example, we could do it by getters (?)
            let logger = Logging.createLogger(category: .todo(.improve("Performance issues")))
            os_log(.debug, log: logger, "We intentionally disable publisher. We could live without this publisher and only debounce our work.")
//            self.textStorageEventsPublisher = .empty()
            self.contextualMenuPublisher = self.contextualMenuSubject.eraseToAnyPublisher()
            
            self.firstResponderChangePublisher = self.firstResponderChangeSubject.eraseToAnyPublisher()
        }
        
        override func becomeFirstResponder() -> Bool {
            let value = super.becomeFirstResponder()
            self.firstResponderChangeSubject.send(.become)
            return value
        }
        
        override func resignFirstResponder() -> Bool {
            let value = super.resignFirstResponder()
            self.firstResponderChangeSubject.send(.resign)
            return value
        }
    }
}

// MARK: Contextual Menu
extension Namespace.TextViewWithPlaceholder {
    private class ContextualMenuItem: UIMenuItem {
        var payload: TextView.UIKitTextView.ContextualMenu.Action
        init(title: String, action: Selector, payload: TextView.UIKitTextView.ContextualMenu.Action) {
            self.payload = payload
            super.init(title: title, action: action)
        }
        convenience init(action: Selector, payload: TextView.UIKitTextView.ContextualMenu.Action) {
            self.init(title: TextView.UIKitTextView.ContextualMenu.Resources.Title.title(for: payload), action: action, payload: payload)
        }
    }
    @objc private func contextualMenuItemDidSelectedForStyle() {
        self.contextualMenuSubject.send(.style)
    }
    @objc private func contextualMenuItemDidSelectedForColor() {
        self.contextualMenuSubject.send(.color)
    }
    @objc private func contextualMenuItemDidSelectedForBackground() {
        self.contextualMenuSubject.send(.background)
    }
    fileprivate func setupMenu() {
        let menu = UIMenuController.shared
        menu.menuItems = [ContextualMenuItem].init([
            .init(action: #selector(contextualMenuItemDidSelectedForStyle), payload: .style),
            .init(action: #selector(contextualMenuItemDidSelectedForColor), payload: .color),
            .init(action: #selector(contextualMenuItemDidSelectedForBackground), payload: .background)
        ])
    }
}

// MARK: - NSTextStorageDelegate
/// As soon as we use `textStorage.setAttributedString`, we couldn't catch event via `.textDidChange`.
/// We could do it only by `textStorage.delegate` methods ( or textStorage notifications ).
///
extension Namespace.TextViewWithPlaceholder: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        self.syncPlaceholder()
        
        var textAlignment: NSTextAlignment = self.textAlignment
        if textStorage.length != 0 {
            let logger = Logging.createLogger(category: .textViewUIKitTextView)
                        
            let range: NSRange = .init(location: 0, length: textStorage.length)
            let attributes = textStorage.attributes(at: 0, longestEffectiveRange: nil, in: range)
            let paragraph = attributes[.paragraphStyle] as? NSParagraphStyle
            
            let paragraphAlignment = paragraph?.alignment
            /// Uncomment when you would like to look at different text alignment :D
//            os_log(.debug, log: logger, "textAlignment: %@", String(describing: NSTextAlignment.Printer.print(self.textAlignment)))
//            os_log(.debug, log: logger, "paragraph style alignment: %@", NSTextAlignment.Printer.print(paragraphAlignment))
            
            textAlignment = paragraphAlignment ?? textAlignment
        }
        
        /// TODO: We must embed textAlignment into our MarksStyle.
        /// But for now, it is ok to do the following trick.
        /// self.textAlignment is out of sync with paragraph style ( which has actual alignment )
        /// For example, if you set `textView.textAlignment` it may have previous value ( was .center ).
        /// But first letter of attributes ( `NSParagraphStyle.alignment` ) has right alignment ( now .right )
        ///
        coordinator?.notifySubscribers(.init(attributedText: textStorage, textAlignment: textAlignment))
//        self.textStorageEventsSubject.send(.didProcessEditing(.init(attributedText: textStorage, textAlignment: textAlignment)))
    }
}

/// TODO: Remove this printer when you are move textAlignment to MarksStyle.
/// Actually, we should extract textAlignment from MarksStyle.
/// In this case we even don't need correct order of applying alignment.
///
extension Namespace.TextViewWithPlaceholder {
    enum TextAlignmentPrinter {
        static func print(_ alignment: NSTextAlignment?) -> String {
            guard let alignment = alignment else { return "" }
            switch alignment {
            case .left: return "left"
            case .center: return "center"
            case .right: return "right"
            case .justified: return "justified"
            case .natural: return "natural"
            @unknown default: return "default"
            }
        }
    }
}

// MARK: - Placeholder
extension Namespace.TextViewWithPlaceholder {
    fileprivate func syncPlaceholder() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    func update(placeholder: NSAttributedString?) {
        self.placeholderLabel.attributedText = placeholder
        // TODO: Add redrawing?
    }
}

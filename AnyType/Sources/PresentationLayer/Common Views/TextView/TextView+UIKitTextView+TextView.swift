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

private extension Logging.Categories {
    static let textViewUIKitTextView: Self = "TextView.UIKitTextView"
}

extension TextView.UIKitTextView {
    enum ContextualMenu {}
}

extension TextView.UIKitTextView.ContextualMenu {
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

extension TextView.UIKitTextView {
    class TextViewWithPlaceholder: UITextView {
        
        // MARK: Publishers
        enum TextStorageEvent {
            struct Payload {
                var attributedText: NSAttributedString
                var textAlignment: NSTextAlignment
            }
            case willProcessEditing(Payload)
            case didProcessEditing(Payload)
        }
        
        var textStorageEventsSubject: PassthroughSubject<TextStorageEvent, Never> = .init()
        var contextualMenuSubject: PassthroughSubject<ContextualMenu.Action, Never> = .init()
        
        // MARK: Variables
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Views
        private lazy var placeholderLabel: UILabel? = {
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
            self.setupUIElements()
            self.updatePlaceholderLayout()
            self.setupMenu()
        }
        
        private func setupUIElements() {
            self.textStorage.delegate = self
            if let view = self.placeholderLabel {
                self.addSubview(view)
            }
        }
                
        // MARK: Add Layout
        private func updatePlaceholderLayout() {
            if let view = self.placeholderLabel, let superview = view.superview {
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
    }
}

// MARK: Contextual Menu
extension TextView.UIKitTextView.TextViewWithPlaceholder {
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
extension TextView.UIKitTextView.TextViewWithPlaceholder: NSTextStorageDelegate {
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
        self.textStorageEventsSubject.send(.didProcessEditing(.init(attributedText: textStorage, textAlignment: textAlignment)))
    }
}

/// TODO: Remove this printer when you are move textAlignment to MarksStyle.
/// Actually, we should extract textAlignment from MarksStyle.
/// In this case we even don't need correct order of applying alignment.
///
extension NSTextAlignment {
    enum Printer {
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
extension TextView.UIKitTextView.TextViewWithPlaceholder {
    fileprivate func syncPlaceholder() {
        self.placeholderLabel?.isHidden = !self.text.isEmpty
    }
    
    func update(placeholder: NSAttributedString?) {
        self.placeholderLabel?.attributedText = placeholder
        // TODO: Add redrawing?
    }
}

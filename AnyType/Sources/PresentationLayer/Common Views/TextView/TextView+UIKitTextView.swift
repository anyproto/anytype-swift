//
//  TextView+UIKitTextView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension TextView {
    class UIKitTextView: UIView {
        // MARK: ViewModel
        weak var model: ViewModel?
        
        // MARK: Resources
        struct Resources {}
        
        // MARK: TODO: Remove
        var getTextView: UITextView? {
            return textView
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
            _ = self.model?.$update.sink(receiveValue: {[weak self] value in self?.onUpdate(value)})
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
                self.textView.textStorage.replaceCharacters(in: NSRange.init(location: 0, length: self.textView.textStorage.length), with: value)
            }
        }
    }
}

// MARK: Configuration
extension TextView.UIKitTextView {
    func configured(_ model: ViewModel?) -> Self {
        self.model = model
        self.setup()
        
        return self
    }
}

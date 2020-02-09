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
            _ = self.model?.$update.sink(receiveValue: self.onUpdate(_:))
        }
        
        // MARK: UI Elements
        private func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.textView = {
                let view = self.model?.createInnerView() ?? .init()
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
        case let .text(value): self.textView.textStorage.setAttributedString(NSAttributedString.init(string: value))
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

//
//  MultiSelectionPane+UIKit+Panes+Toolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

fileprivate typealias Namespace = MultiSelectionPane.UIKit.Panes
fileprivate typealias FileNamespace = Namespace.Toolbar

extension Namespace {
    enum Toolbar {}
}

// MARK: View
extension FileNamespace {
    class View: UIView {
        // MARK: Aliases
        typealias BaseToolbarView = TextView.BaseSingleToolbarView
        typealias Style = TextView.Style

        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var subscription: AnyCancellable?

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }
        
        init(viewModel: ViewModel) {
            self.model = viewModel
            super.init(frame: .zero)
            self.setup()
        }
        
        // MARK: Actions
        private func update(response: UserResponse) {
            switch response {
            case .isEmpty:
                self.titleLabel.text = "Select or drag and drop blocks"
                self.stackView.isHidden = true
            case let .nonEmpty(value):
                self.titleLabel.text = "\(value) blocks selected"
                self.stackView.isHidden = false
            }
        }
        
        @objc private func processTurnInto() {
            process(.turnInto)
        }

        @objc private func processDelete() {
            process(.delete)
        }

        @objc private func processCopy() {
            process(.copy)
        }

        private func process(_ action: Action) {
            self.model.process(action: action)
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        private func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()

            for button in [self.turnIntoButton, self.deleteButton, self.copyButton] {
                button?.tintColor = self.style.normalColor()
            }

            self.turnIntoButton.addTarget(self, action: #selector(Self.processTurnInto), for: .touchUpInside)
            self.deleteButton.addTarget(self, action: #selector(Self.processDelete), for: .touchUpInside)
            self.copyButton.addTarget(self, action: #selector(Self.processTurnInto), for: .touchUpInside)
        }

        private func setupInteraction() {
            self.subscription = self.model.userResponse.sink { [weak self] (value) in
                self?.update(response: value)
            }
        }

        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        private var titleLabel: UILabel!
        private var turnIntoButton: UIButton!
        private var deleteButton: UIButton!
        private var copyButton: UIButton!

        private var stackView: UIStackView!
        private var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.titleLabel = {
                let view = UILabel()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.turnIntoButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/AddBlock"), for: .normal)
                return view
            }()

            self.deleteButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/MultiActionMenu"), for: .normal)
                return view
            }()

            self.copyButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/DismissKeyboard"), for: .normal)
                return view
            }()

            self.stackView = {
                let view = UIStackView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.axis = .horizontal
                view.distribution = .fillProportionally
                return view
            }()

            for view in [self.turnIntoButton, self.deleteButton, self.copyButton].compactMap({$0}) {
                self.stackView.addArrangedSubview(view)
            }

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(self.titleLabel)
            self.contentView.addSubview(self.stackView)
            self.addSubview(self.contentView)
        }

        // MARK: Layout
        func addLayout() {
            let offset: CGFloat = 10
            if let view = self.titleLabel, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.stackView, let superview = view.superview, let leftView = self.titleLabel {
                view.leadingAnchor.constraint(greaterThanOrEqualTo: leftView.trailingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -offset).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }

            if let view = self.contentView, let superview = view.superview {
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

// MARK: States
extension FileNamespace {
    // MARK: Action
    enum Action {
        case turnInto
        case delete
        case copy
    }
    
    // MARK: State
    /// Internal State for View.
    /// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
    ///
    enum UserResponse {
        case isEmpty
        case nonEmpty(UInt)
    }
}

// MARK: ViewModel
extension FileNamespace {
    class ViewModel {
        // MARK: Initialization
        init() {
            self.setup()
        }

        // MARK: Setup
        func setup() {
            self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            self.userAction = self.userActionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        }

        // MARK: Publishers
        
        /// From OuterWorld
        private var subscription: AnyCancellable?
        private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
        fileprivate var userResponse: AnyPublisher<UserResponse, Never> = .empty()
                
        /// To OuterWorld
        private var userActionSubject: PassthroughSubject<Action?, Never> = .init()
        var userAction: AnyPublisher<Action, Never> = .empty()

        // MARK: Private Setters
        fileprivate func process(action: Action) {
            self.userActionSubject.send(action)
        }
        
        // MARK: Public Setters
        /// Use this method from outside to update value.
        ///
        func handle(countOfObjects: Int) {
            self.userResponseSubject.send(countOfObjects <= 0 ? .isEmpty : .nonEmpty(.init(countOfObjects)))
        }
        
        func subscribe(on userResponse: AnyPublisher<Int, Never>) {
            self.subscription = userResponse.sink(receiveValue: { [weak self] (value) in
                self?.handle(countOfObjects: value)
            })
        }
        
        func configured(userResponseStream: AnyPublisher<Int, Never>) -> Self {
            self.subscribe(on: userResponseStream)
            return self
        }
    }
}

//
//  TextView+ActionsAccessoryView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 23.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

private extension Logging.Categories {
    static let textViewActionsToolbar: Self = "TextView.ActionsToolbar"
}

// MARK: BlockToolbar
extension TextView.ActionsToolbar {
    class AccessoryView: UIView {
        // MARK: Aliases
        typealias BaseToolbarView = TextView.BaseSingleToolbarView
        typealias Style = TextView.Style

        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var userResponse: AnyCancellable?

        // MARK: Updates
        func update(state: State) {
            func button(for state: State) -> UIButton? {
                switch state {
                case .unknown: return nil
                case .addBlock: return self.addBlockButton
                case .multiActionMenu: return self.multiActionMenuButton
                case .keyboardDismiss: return nil
                }
            }

            let selectedButton = button(for: state)
            let otherButtons = [addBlockButton, multiActionMenuButton].filter { $0 != selectedButton }

            UIView.animate(withDuration: 0.3) {
                for button in otherButtons {
                    button?.backgroundColor = self.style.normalColor()
                }
                selectedButton?.backgroundColor = self.style.highlightedColor()
            }
        }

        // MARK: Initialization
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.setup()
        }

        // MARK: Actions
        @objc func processAddBlock() {
            process(.addBlock)
        }

        @objc func processMultiActionMenu() {
            process(.multiActionMenu)
        }

        @objc func processDismissKeyboard() {
            process(.keyboardDismiss)
        }

        func process(_ action: Action) {
            self.model.process(action)
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()

            for button in [addBlockButton, multiActionMenuButton, dismissKeyboardButton] {
                button?.tintColor = self.style.normalColor()
            }

            self.addBlockButton.addTarget(self, action: #selector(Self.processAddBlock), for: .touchUpInside)
            self.multiActionMenuButton.addTarget(self, action: #selector(Self.processMultiActionMenu), for: .touchUpInside)
            self.dismissKeyboardButton.addTarget(self, action: #selector(Self.processDismissKeyboard), for: .touchUpInside)
        }

        func setupInteraction() {
            self.userResponse = self.model.$userResponse.dropFirst().sink { [weak self] (state) in
                self?.update(state: state)
            }
        }

        // MARK: Setup
        func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        private var addBlockButton: UIButton!
        private var multiActionMenuButton: UIButton!
        private var dismissKeyboardButton: UIButton!

        private var toolbarView: BaseToolbarView!
        private var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {
            self.autoresizingMask = .flexibleHeight
            self.addBlockButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/AddBlock"), for: .normal)
                return view
            }()

            self.multiActionMenuButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/MultiActionMenu"), for: .normal)
                return view
            }()

            self.dismissKeyboardButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Toolbar/Blocks/New/ActionsToolbar/DismissKeyboard"), for: .normal)
                return view
            }()

            self.toolbarView = {
                let view = BaseToolbarView()
                return view
            }()

            for view in [addBlockButton, multiActionMenuButton, dismissKeyboardButton].compactMap({$0}) {
                toolbarView.stackView.addArrangedSubview(view)
            }

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()

            self.contentView.addSubview(self.toolbarView)
            self.addSubview(self.contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.contentView, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            if let view = self.toolbarView, let superview = view.superview {
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

// MARK: ViewModel
extension TextView.ActionsToolbar {
    // MARK: Action
    enum Action {
        case unknown
        case addBlock
        case multiActionMenu
        case keyboardDismiss
    }
    // MARK: State
    /// Internal State for View.
    /// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
    ///
    enum State {
        case unknown
        case addBlock
        case multiActionMenu
        case keyboardDismiss
    }

    struct UserAction {
        var action: Action = .unknown
        var view: UIView?
        static var zero = Self.init()
    }

    // MARK: ViewModel
    class ViewModel: NSObject, ObservableObject {
        // MARK: Initialization
        override init() {
            super.init()
            self.setup()
        }

        // MARK: Setup
        func setup() {
            self.allInOnePublisher = self.$userAction.map(\.action).map {
                switch $0 {
                case .unknown: return nil
                case .keyboardDismiss: return nil
                case .addBlock: return .addBlockAction(.addBlock)
                case .multiActionMenu: return .showMultiActionMenuAction(.showMultiActionMenu)
                }
            }.eraseToAnyPublisher()
            self.allInOneStreamDescription = self.allInOnePublisher.sink { value in
                let logger = Logging.createLogger(category: .textViewActionsToolbar)
                os_log(.debug, log: logger, "ActionsToolbarViewModel underlying action %@", "\(String(describing: value))")
            }
        }

        // MARK: Publishers
        @Published fileprivate var userResponse: State = .unknown
        @Published var userAction: UserAction = .zero

        // MARK: Streams
        private var allInOneStreamDescription: AnyCancellable?
        var allInOnePublisher: AnyPublisher<TextView.UserAction?, Never> = .empty()

        // MARK: Private Setters
        fileprivate func process(_ action: Action) {
            switch action {
            case .unknown: return
            case .addBlock: self.userAction = .init(action: .addBlock, view: nil)
            case .multiActionMenu: self.userAction = .init(action: .multiActionMenu, view: nil)
            case .keyboardDismiss: self.userAction = .init(action: .keyboardDismiss, view: nil)
            }
        }
    }
}

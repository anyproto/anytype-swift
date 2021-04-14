//
//  MultiSelectionPane+UIKit+Panes+Toolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine

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
        
        private let insets: UIEdgeInsets

        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var subscription: AnyCancellable?

        // MARK: Initialization
        init(frame: CGRect,
             applicationWindowInsetsProvider: ApplicationWindowInsetsProvider = UIApplication.shared) {
            self.insets = UIEdgeInsets(top: 10,
                                       left: 10,
                                       bottom: applicationWindowInsetsProvider.mainWindowInsets.bottom,
                                       right: 10)
            super.init(frame: frame)
            self.setup()
        }
        
        init(viewModel: ViewModel,
             applicationWindowInsetsProvider: ApplicationWindowInsetsProvider = UIApplication.shared) {
            self.model = viewModel
            self.insets = UIEdgeInsets(top: 10,
                                       left: 10,
                                       bottom: applicationWindowInsetsProvider.mainWindowInsets.bottom,
                                       right: 10)
            super.init(frame: .zero)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: Actions
        private func update(response: UserResponse) {
            switch response {
            case .isEmpty:
                self.titleLabel.text = NSLocalizedString("Select or drag and drop blocks", comment: "")
                self.turnIntoButton.isHidden = true
                self.copyButton.isHidden = true
                self.deleteButton.isHidden = true
            case let .nonEmpty(count, showTurnInto):
                self.titleLabel.text = String(count) + " " + NSLocalizedString("Blocks selected", comment: "")
                self.turnIntoButton.isHidden = !showTurnInto
                self.copyButton.isHidden = false
                self.deleteButton.isHidden = false
            }
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        private func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()

            for button in [self.turnIntoButton, self.deleteButton, self.copyButton] {
                button?.tintColor = self.style.normalColor()
            }
            self.turnIntoButton.addAction(UIAction(handler: { [weak self] _ in
                self?.model.process(action: .turnInto)
            }), for: .touchUpInside)
            self.deleteButton.addAction(UIAction(handler: { [weak self] _ in
                self?.model.process(action: .delete)
            }), for: .touchUpInside)
            self.copyButton.addAction(UIAction(handler: { [weak self] _ in
                self?.model.process(action: .copy)
            }), for: .touchUpInside)
        }

        private func setupInteraction() {
            self.subscription = self.model.userResponse.sink { [weak self] (value) in
                self?.update(response: value)
            }
        }

        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        private var titleLabel: UILabel!
        private var turnIntoButton: UIButton!
        private var deleteButton: UIButton!
        private var copyButton: UIButton!

        // MARK: Setup UI Elements
        private func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.titleLabel = {
                let view = UILabel()
                view.textColor = .accentItemColor
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.turnIntoButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/TurnInto"), for: .normal)
                return view
            }()

            self.deleteButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/Delete"), for: .normal)
                return view
            }()

            self.copyButton = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setImage(UIImage(named: "TextEditor/Panes/MultiSelection/Toolbar/More"), for: .normal)
                return view
            }()
            
            let flexibleView = UIView()
            flexibleView.translatesAutoresizingMaskIntoConstraints = false
            flexibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            flexibleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let stackView = UIStackView(arrangedSubviews: [self.titleLabel,
                                                           flexibleView,
                                                           self.turnIntoButton,
                                                           self.deleteButton,
                                                           self.copyButton])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally

            self.addSubview(stackView)
            stackView.edgesToSuperview(insets: insets)
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
        case nonEmpty(count: UInt, showTurnInto: Bool)
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
        func handle(countOfObjects: Int, hasTurnIntoCommand: Bool) {
            self.userResponseSubject.send(countOfObjects <= 0 ? .isEmpty : .nonEmpty(count: .init(countOfObjects), showTurnInto: hasTurnIntoCommand))
        }
        
        func subscribe(on userResponse: AnyPublisher<MultiSelectionPane.UIKit.Main.UserResponse, Never>) {
            self.subscription = userResponse.sink(receiveValue: { [weak self] (value) in
                self?.handle(countOfObjects: value.selectedItemsCount,
                             hasTurnIntoCommand: value.hasTurnIntoCommand)
            })
        }
        
        func configured(userResponseStream: AnyPublisher<MultiSelectionPane.UIKit.Main.UserResponse, Never>) -> Self {
            self.subscribe(on: userResponseStream)
            return self
        }
    }
}

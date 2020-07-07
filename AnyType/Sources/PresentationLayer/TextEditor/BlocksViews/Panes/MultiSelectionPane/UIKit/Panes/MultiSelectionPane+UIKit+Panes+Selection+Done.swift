//
//  MultiSelectionPane+UIKit+Panes+Selection+Done.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 30.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os

fileprivate typealias Namespace = MultiSelectionPane.UIKit.Panes.Selection
fileprivate typealias FileNamespace = Namespace.Done

// MARK: View / SelectAll
extension Namespace {
    enum Done {}
}

// MARK: View / SelectAll / Actions
extension FileNamespace {
    enum Action {
        case done
    }

    enum UserResponse {}
}

// MARK: View / SelectAll
extension FileNamespace {
    class View: UIView {
        /// Aliases
        fileprivate typealias Style = Namespace.View.Style
        
        /// Variables
        private var style: Style = .default
        private var model: ViewModel = .init()
        
        /// Initialization
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
        
        /// Actions
        private func update(response: UserResponse) {
            /// Fill if you need a reaction on UserResponse
        }
        
        @objc func processOnClick() {
            self.process(.done)
        }
        private func process(_ action: Action) {
            self.model.process(action: action)
        }
        
        /// Setup
        private func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()

            for button in [self.button] {
                button?.tintColor = self.style.normalColor()
            }

            self.button.addTarget(self, action: #selector(Self.processOnClick), for: .touchUpInside)
        }

        private func setupInteraction() {}

        // MARK: Setup
        private func setup() {
            self.setupUIElements()
            self.addLayout()
            self.setupCustomization()
            self.setupInteraction()
        }

        // MARK: UI Elements
        private var button: UIButton!
        private var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.button = {
                let view = UIButton(type: .system)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.titleLabel?.font = .preferredFont(forTextStyle: .title3)
                view.setTitle("Done", for: .normal)
                return view
            }()

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView.addSubview(self.button)
            self.addSubview(self.contentView)
        }

        // MARK: Layout
        func addLayout() {
            if let view = self.button, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
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

// MARK: View / SelectAll / UIBarButtonItem
extension FileNamespace {
    /// TODO: Move later whole setup to UIAction.
//    class CustomUIAction: UIAction {
//        private var model: ViewModel = .init()
//        private var userResponseSubscription: AnyCancellable?
//        private var anySelectionSubscription: AnyCancellable?
//        @Published var isAnySelection: Bool? = false
//
//        init(viewModel: ViewModel) {
////            self.model = viewModel
//        }
//
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//        ///
//    }
    
    class BarButtonItem: UIBarButtonItem {

        /// Variables
        private var model: ViewModel

        /// Initialization
        init(viewModel: ViewModel) {
            self.model = viewModel
            super.init()
            self.title = "Done"
            self.setup()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        /// Actions
        private func update(response: UserResponse) {}

        @objc func processOnClick() {
            self.process(.done)
        }
        private func process(_ action: Action) {
            self.model.process(action: action)
        }
        
        /// Setup
        private func setupCustomization() {
            self.target = self
            self.action = #selector(processOnClick)
        }
        
        private func setupInteraction() {}
        
        private func setup() {
            self.setupCustomization()
            self.setupInteraction()
        }
    }
}


// MARK: View / SelectAll / ViewModel
extension FileNamespace {
    class ViewModel {
        /// Initialization
        init() {
            self.setup()
        }

        /// Setup
        func setup() {
            self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            self.userAction = self.userActionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        }

        /// Publishers
        
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
        
    }
}


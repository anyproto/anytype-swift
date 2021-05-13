//
//  MultiSelectionPane+UIKit+Panes+Selection.swift
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
fileprivate typealias FileNamespace = Namespace.Selection

extension Namespace {
    enum Selection {}
}

// MARK: View
extension FileNamespace {
    class View: UIView {
        // MARK: Aliases
        typealias Style = BlockTextView.Style

        // MARK: Variables
        var style: Style = .default
        var model: ViewModel = .init()
        var userResponseSubscription: AnyCancellable?

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
            // send to a view model (?)
        }

        // MARK: Public API Configurations
        // something that we should put in public api.

        private func setupCustomization() {
            self.backgroundColor = self.style.backgroundColor()
        }

        private func setupInteraction() {
            self.userResponseSubscription = self.model.userResponse.sink { [weak self] (value) in
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
        private var selectionButton: SelectAll.View!
        private var doneButton: Done.View!

        private var contentView: UIView!

        // MARK: Setup UI Elements
        func setupUIElements() {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.selectionButton = {
                // Ask view model for correct view model.
                .init(viewModel: self.model.selectAllViewModel())
            }()

            self.doneButton = {
                .init(viewModel: self.model.doneViewModel())
            }()

            self.contentView = {
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                return view
            }()
            
            self.contentView.addSubview(self.selectionButton)
            self.contentView.addSubview(self.doneButton)
            self.addSubview(self.contentView)
        }

        // MARK: Layout
        func addLayout() {
            let offset: CGFloat = 10
            if let view = self.selectionButton, let superview = view.superview {
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset).isActive = true
                view.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
            }
            
            if let view = self.doneButton, let superview = view.superview, let leftView = self.selectionButton {
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
        case selectAll(SelectAll.Action)
        case done(Done.Action)
    }
    
    // MARK: State
    /// Internal State for View.
    /// For example, if you press button which doesn't hide keyboard, by design, this button could be highlighted.
    ///
    enum UserResponse {
        case selection(SelectAll.UserResponse)
    }
}

// MARK: ViewModel Composition
// TODO: Add cache if needed.
extension FileNamespace.ViewModel {
    func selectAllViewModel() -> MultiSelectionPane.UIKit.Panes.Selection.SelectAll.ViewModel {
        self._selectAllViewModel
    }
    
    func doneViewModel() -> MultiSelectionPane.UIKit.Panes.Selection.Done.ViewModel {
        self._doneViewModel
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
            
            // From OuterWorld
            self.userResponse = self.userResponseSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            
            _ = self._selectAllViewModel.configured(userResponseStream: self.userResponse.map { value -> SelectAll.UserResponse in
                switch value {
                case let .selection(value): return value
                }
            }.eraseToAnyPublisher())
            
            // To OuterWorld
            self.userAction = Publishers.Merge(self._selectAllViewModel.userAction.map(Action.selectAll), self._doneViewModel.userAction.map(Action.done)).eraseToAnyPublisher()
        }
        
        // MARK: ViewModels
        private var _selectAllViewModel: FileNamespace.SelectAll.ViewModel = .init()
        private var _doneViewModel: FileNamespace.Done.ViewModel = .init()
        
        // MARK: Publishers
        private var subscription: AnyCancellable?
        
        /// From OuterWorld
        private var userResponseSubject: PassthroughSubject<UserResponse?, Never> = .init()
        fileprivate var userResponse: AnyPublisher<UserResponse, Never> = .empty()
                
        /// To OuterWorld
        var userAction: AnyPublisher<Action, Never> = .empty()

        // MARK: Public Setters
        /// Use this method from outside to update value.
        ///
        func handle(countOfObjects: Int) {
            self.userResponseSubject.send(.selection(countOfObjects <= 0 ? .isEmpty : .nonEmpty(UInt(countOfObjects))))
        }
        
        func configured(userResponseStream: AnyPublisher<Int, Never>) -> Self {
            self.subscription = userResponseStream.sink(receiveValue: { [weak self] (value) in
                self?.handle(countOfObjects: value)
            })
            return self
        }
    }
}

// MARK: Builder
extension FileNamespace.Assembly {
    private enum Builder {
        typealias ViewModel = FileNamespace.ViewModel
        static func buildView(viewModel: ViewModel, kind: Kind) -> UIView {
            switch kind {
            case .selectAll: return FileNamespace.SelectAll.View.init(viewModel: viewModel.selectAllViewModel())
            case .done: return FileNamespace.Done.View.init(viewModel: viewModel.doneViewModel())
            }
        }
        
        static func buildBarItem(viewModel: ViewModel, kind: Kind) -> UIBarButtonItem {
            switch kind {
            case .selectAll: return FileNamespace.SelectAll.BarButtonItem.init(viewModel: viewModel.selectAllViewModel())
            case .done: return FileNamespace.Done.BarButtonItem.init(viewModel: viewModel.doneViewModel())
            }
        }
    }
}

// MARK: Assembly
extension FileNamespace {
    struct Assembly {
        enum Kind {
            case selectAll
            case done
        }

        private(set) var viewModel: ViewModel = .init()
        func buildView() -> UIView {
            View.init(viewModel: self.viewModel)
        }
        
        private func buildSelectAllView() -> UIView {
            Builder.buildView(viewModel: self.viewModel, kind: .selectAll)
        }
        
        private func buildDoneView() -> UIView {
            Builder.buildView(viewModel: self.viewModel, kind: .done)
        }
        
        func buildBarButtonItem(of kind: Kind) -> UIBarButtonItem {
            Builder.buildBarItem(viewModel: self.viewModel, kind: kind)
        }
    }
}

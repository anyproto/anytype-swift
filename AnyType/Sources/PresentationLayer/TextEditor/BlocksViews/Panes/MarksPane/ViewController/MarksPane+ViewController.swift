//
//  MarksPane+ViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import os

extension MarksPane {
    class ViewController: UIViewController {
        // MARK: Variables
        private var model: ViewModel
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Setup
        private func setupSubscriptions() {
            self.model.dismissActionPublisher.sink { [weak self] (value) in
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &self.subscriptions)
        }
        
        private func setup() {
            self.setupSubscriptions()
        }
        
        // MARK: Initialization
        init(model: ViewModel) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - View Lifecycle
extension MarksPane.ViewController {
    private func setupUIElements() {
        let chosenData = self.model.chosenView()
        if let chosenView = chosenData.view {
            self.view.addSubview(chosenView)
            self.addLayout(forView: chosenView)
        }
        
        // TODO: Remove it later and put somewhere else?
        // Bad style, but ok for now.
        if let payload = chosenData.payload {
            let logger = Logging.createLogger(category: .todo(.refactor("Refactor later")))
            os_log(.debug, log: logger, "We should not inject title via Apple bad design of view controllers. Don't use navigation item.")
            self.navigationItem.title = payload.title
        }
    }
    
    private func addLayout(forView view: UIView) {
        if let superview = view.superview {
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
    }
}

// MARK: ViewBuilder
extension MarksPane.ViewController {
    enum ViewBuilder {
    }
}

// MARK: ViewModel
extension MarksPane.ViewController {
    class ViewModel {
        typealias UnderlyingAction = MarksPane.Main.Action
        
        // MARK: Variables
        
        var subscription: AnyCancellable?
        
        // MARK: Publishers
        var action: AnyPublisher<UnderlyingAction, Never> = .empty()
        var dismissActionPublisher: AnyPublisher<Void, Never> = .empty()
        
        // MARK: Style
        private var style: Style
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
                
        // MARK: Models
        private var viewModelHolder: MarksPane.Main.ViewModelHolder = .init()
        
        // MARK: Setup
//        private func publisher(style: Style) -> AnyPublisher<UnderlyingAction, Never> {
//            switch style {
//            case .addBlock: return self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
//                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
//            }.eraseToAnyPublisher()
//            case .turnIntoBlock: return self.turnIntoBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
//                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
//            }.eraseToAnyPublisher()
//            }
//        }
        private func setup(style: Style) {
            self.action = self.viewModelHolder.viewModel.userAction
            
            if let section = style.section {
                self.viewModelHolder.viewModel.update(category: section)
            }
            if let userResponse = style.userResponse {
                self.viewModelHolder.viewModel.update(userResponse)
            }
//            self.action = self.publisher(style: style)
//            self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
        }
        
        // MARK: Initialization
        private init(_ style: Style) {
            self.style = style
            self.dismissActionPublisher = self.viewModelHolder.viewModel.dismissAction
            self.setup(style: style)
        }
        
        // MARK: Public Create
        class func create(_ style: Style) -> ViewModel { .init(style) }
        
        // MARK: Get Chosen View
        
        func chosenView() -> StyleAndViewAndPayload {
            let view = self.viewModelHolder.createView()
            return .init(payload: nil, style: self.style, view: view)
        }
        
        func configured(_ stylePublisher: AnyPublisher<Style?, Never>) {
            self.subscription = stylePublisher.safelyUnwrapOptionals().sink { [weak self] value in
                self?.style = value
                self?.setup(style: value)
            }
        }
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension MarksPane.ViewController.ViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<MarksPane.ViewController.ViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension MarksPane.ViewController.ViewModel {
    /// Data structure which encapsulates style, view and payload if it is necessary for a final view controller that will be presented.
    struct StyleAndViewAndPayload {
        /// Payload could contain any information for view controller, for example, a title.
        ///
        struct Payload {
            let title: String
        }
        
        let payload: Payload?
        
        /// Style configures `style` of view controller data.
        /// In our case `Style` permits or prohibits categories of `MarksPane.Main.Section`
        ///
        let style: Style
        
        /// View is a UIview that stores SwiftUI view.
        /// We could add it as subview of view controller's view.
        ///
        let view: UIView?
    }
}

// MARK: Style
extension MarksPane.ViewController.ViewModel {
    /// A Style that contains of a visible components of our view.
    /// This style is a inclusive set of style, color and backgroundColor.
    /// These options refer to Categories in `MarksPane.Main.Section`
    ///
    struct Style {
        fileprivate var section: MarksPane.Main.Section.Category?
        fileprivate var userResponse: MarksPane.Main.RawUserResponse?
        init(section: MarksPane.Main.Section.Category?, userResponse: MarksPane.Main.RawUserResponse?) {
            self.section = section
            self.userResponse = userResponse
        }
        init() {}
    }
}

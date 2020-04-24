//
//  BlocksViews+Toolbar+ViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import os

extension BlocksViews.Toolbar {
    class ViewController: UIViewController {
        // MARK: Variables
        private var model: ViewModel
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
        
        // MARK: Setup
        private func setupSubscriptions() {
            self.model.dismissControllerPublisher.sink { [weak self] (value) in
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
extension BlocksViews.Toolbar.ViewController {
    private func setupUIElements() {
        // TODO: Move to Schemes
        let appearance = UITableViewHeaderFooterView.appearance()
        let sectionView: UIView = .init()
        sectionView.backgroundColor = .white
        appearance.backgroundView = sectionView
                
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
extension BlocksViews.Toolbar.ViewController {
    enum ViewBuilder {
    }
}

// MARK: ViewModel
extension BlocksViews.Toolbar.ViewController {
    class ViewModel {
        typealias UnderlyingAction = BlocksViews.Toolbar.UnderlyingAction
        typealias Toolbar = BlocksViews.Toolbar
        
        // MARK: Variables
        var action: AnyPublisher<UnderlyingAction, Never> = .empty()
        var dismissControllerPublisher: AnyPublisher<Void, Never> = .empty()
        private var style: Style
        
        // MARK: Subscriptions
        private var subscriptions: Set<AnyCancellable> = []
                
        // MARK: Models
        @ObservedObject private var addBlockViewModel: Toolbar.AddBlock.ViewModel
        @ObservedObject private var turnIntoBlockViewModel: Toolbar.TurnIntoBlock.ViewModel
        
        // MARK: Setup
        private func publisher(style: Style) -> AnyPublisher<UnderlyingAction, Never> {
            switch style {
            case .addBlock: return self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
            }.eraseToAnyPublisher()
            case .turnIntoBlock: return self.turnIntoBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
            }.eraseToAnyPublisher()
            }
        }
        private func setup(style: Style) {
            self.action = self.publisher(style: style)
            self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
        }
        
        // MARK: Initialization
        private init(_ style: Style) {
            self.style = style
            self.addBlockViewModel = Toolbar.AddBlock.ViewModelBuilder.create()
            self.turnIntoBlockViewModel = Toolbar.TurnIntoBlock.ViewModelBuilder.create()
            self.setup(style: style)
        }
        
        // MARK: Public Create
        class func create(_ style: Style) -> ViewModel {
            ViewModel(style)
        }
        
        // MARK: Get Chosen View
        func chosenView() -> StyleAndViewAndPayload {
            switch self.style {
            case .addBlock: return .init(style: self.style, view: Toolbar.AddBlock.InputViewBuilder.createView(self._addBlockViewModel), payload: .init(title: self.addBlockViewModel.title))
            case .turnIntoBlock: return .init(style: self.style, view: Toolbar.TurnIntoBlock.InputViewBuilder.createView(self._turnIntoBlockViewModel), payload: .init(title: self.turnIntoBlockViewModel.title))
            }
        }
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension BlocksViews.Toolbar.ViewController.ViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<BlocksViews.Toolbar.ViewController.ViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension BlocksViews.Toolbar.ViewController.ViewModel {
    struct StyleAndViewAndPayload {
        struct Payload {
            let title: String
        }
        let style: Style
        let view: UIView?
        let payload: Payload?
    }
}

// MARK: Style
extension BlocksViews.Toolbar.ViewController.ViewModel {
    /// Necessary for different toolbars.
    /// We should add turnInto later.
    /// And may be we could add action toolbar here...
    ///
    enum Style {
    case addBlock, turnIntoBlock
    }
}

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
        
        // MARK: Initialization
        init(model: ViewModel) {
            self.model = model
            super.init(nibName: nil, bundle: nil)
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
        private var style: Style
                
        // MARK: Models
        @ObservedObject private var addBlockViewModel: Toolbar.AddBlock.ViewModel
        
        // MARK: Setup
        private func setup() {
            let addBlockPublisher = self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
                UnderlyingAction.addBlock(UnderlyingAction.BlockType.convert(value))
            }
            
            self.action = addBlockPublisher.eraseToAnyPublisher()
        }
        
        // MARK: Initialization
        private init(_ style: Style) {
            self.style = style
            switch style {
            case .addBlock: self.addBlockViewModel = .init()
            }
        }
        
        // MARK: Public Create
        class func create(_ style: Style) -> ViewModel {
            ViewModel(style)
        }
        
        // MARK: Get Chosen View
        func chosenView() -> StyleAndViewAndPayload {
            switch self.style {
            case .addBlock: return .init(style: self.style, view: Toolbar.AddBlock.InputViewBuilder.createView(self._addBlockViewModel), payload: .init(title: self.addBlockViewModel.title))
            }
        }
    }
}

// MARK: StyleAndView
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
    case addBlock//, turnInto
    }
}

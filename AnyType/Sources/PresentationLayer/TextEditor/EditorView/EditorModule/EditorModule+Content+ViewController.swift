//
//  EditorModule+Content+ViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = EditorModule.Content
extension Namespace {
    class ViewController: UIViewController {
        
        private var viewModel: ViewModel
        private var childViewController: UIViewController?
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Setup And Layout
private extension Namespace.ViewController {
    func setupUIElements() {
        if let viewController = self.childViewController {
            self.addChild(viewController)
        }
    }
    
    func addLayout() {
        if let view = self.childViewController?.view {
            self.view.addSubview(view)
            if let superview = view.superview {
                let constraints = [
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
    }
}

// MARK: View Lifecycle
extension Namespace.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
        self.didMove(toParent: self.childViewController)
    }
}

// MARK: Configurations
extension Namespace.ViewController {
    func configured(childViewController: UIViewController?) -> Self {
        self.childViewController = childViewController
        return self
    }
}

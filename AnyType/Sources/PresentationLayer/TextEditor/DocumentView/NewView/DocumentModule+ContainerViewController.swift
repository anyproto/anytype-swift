//
//  DocumentModule+ContainerViewController.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule
extension Namespace {
    typealias TransitionViewController = CommonViews.ViewControllers.TransitionContainerViewController
    class ContainerViewController: UIViewController {
        
        /// Variables
        private var userActionSubject: PassthroughSubject<UserAction, Never> = .init()
        var userActionPublisher: AnyPublisher<UserAction, Never> = .empty()
        
        private var transitionContainer: TransitionViewController = .init()
        private var viewModel: ViewModel
        private var childViewController: UIViewController?
        private var subscription: AnyCancellable?
        private var toRemove: AnyCancellable?
        private var childAsNavigationController: UINavigationController? {
            self.childViewController as? UINavigationController
        }
        
        /// Setup
        func setup() {
            self.configured(actionsPublisher: self.viewModel.actionPublisher())
            self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
        }
                
        /// Initialization
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
            self.setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: Actions Handling
private extension Namespace.ContainerViewController {
    func handle(_ action: ViewModel.Action) {
        switch action {
        case let .child(value): self.childAsNavigationController?.pushViewController(value, animated: true)
        case let .show(value): self.present(value, animated: true, completion: nil)
        case .pop: self.childAsNavigationController?.popViewController(animated: true)
        case let .childDocument(value):
            let viewModel = value.1
            let viewController = value.0
            _ = viewModel.configured(navigationItem: viewController.navigationItem)
            self.handle(.child(value.0))
        case let .showDocument(value):
            let viewModel = value.1
            let viewController = value.0
            _ = viewModel.configured(navigationItem: viewController.navigationItem)
            self.handle(.show(value.0))
        }
    }
}

// MARK: UINavigationController Handling
extension Namespace.ContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        /// We should keep track of navigation links.
        /// Where we should update navigation from item.
        if let controller = viewController as? Namespace.ContentViewController {
            
            if let child = controller.children.first?.children.first as? Namespace.DocumentViewController {
                /// extract model from it.
                let viewModel = child.getViewModel()
                
                /// Tell our view model about update
                _ = self.viewModel.configured(userActionsStream: viewModel.publicUserActionPublisher)
            }
            
        }
    }
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? Namespace.ContentViewController {
            
            if let child = controller.children.first?.children.first as? Namespace.DocumentViewController {
                /// extract model from it.
            }
        }
    }
}

// MARK: Setup And Layout
private extension Namespace.ContainerViewController {
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
    
    func addGestureRecognizer() {
//        let recognizer = UIPanGestureRecognizer.init(target: self, action: #selector(self.didDrag(sender:)))
//        self.view.addGestureRecognizer(recognizer)
    }
    
    func configuredTransitioning() {
        let presentation: TransitionController? = .init()
        let dismissal: TransitionController? = .init()
        _ = dismissal?.configured(transitionDirection: .backward)
        _ = presentation?.configured(presentedViewController: self)
        //        self.transitionContainer.configured
        let containerController = self.transitionContainer
        let resultController = containerController.configured(root: self)
            .configured(presentationAnimator: presentation)
            .configured(presentationInteractor: presentation)
            .configured(dismissalAnimator: dismissal)
            .configured(dismissalInteractor: dismissal)
        self.transitioningDelegate = containerController
        self.modalPresentationStyle = .custom
    }
}

// MARK: Transitioning
extension Namespace.ContainerViewController {
    typealias TransitionController = MarksPane.ViewController.TransitionController
}

// MARK: User Actions
extension Namespace.ContainerViewController {
    enum UserAction {
        case shouldDismiss
    }
}

// MARK: Actions
extension Namespace.ContainerViewController {
    @objc func dismissAction() {
        self.userActionSubject.send(.shouldDismiss)
    }
}

// MARK: Gesture Recognizer
extension Namespace.ContainerViewController {
    @objc func didDrag(sender: UIGestureRecognizer) {
        if let recognizer = sender as? UIPanGestureRecognizer {
            switch recognizer.state {
                
            case .possible: return
            case .began: return
            case .changed:
//                self.view.frame
                let translation = recognizer.translation(in: self.view)
                print("translation: \(translation)")
                var origin = self.view.frame.origin
                let correctTranslation: CGFloat = max(0, translation.y)
                origin.y = correctTranslation
                self.view.frame = .init(origin: origin, size: self.view.frame.size)
            case .ended: return
            case .cancelled: return
            case .failed: return
            @unknown default: return
            }
        }
    }
}

// MARK: View Lifecycle
extension Namespace.ContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
        self.didMove(toParent: self.childViewController)
        self.addGestureRecognizer()
        self.configuredTransitioning()
    }
}

// MARK: Configurations
extension Namespace.ContainerViewController {
    func configured(actionsPublisher: AnyPublisher<ViewModel.Action, Never>) {
        self.subscription = actionsPublisher.sink(receiveValue: { [weak self] (value) in
            self?.handle(value)
        })
    }
    func configured(childViewController: UIViewController?) -> Self {
        self.childViewController = childViewController
        return self
    }
}

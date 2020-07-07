//
//  DocumentModule+ViewControllers.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

fileprivate typealias Namespace = DocumentModule
fileprivate typealias FileNamespace = Namespace.ViewControllers

extension DocumentModule {
    enum ViewControllers {}
}

//
protocol DocumentModuleViewControllersHasOneChildViewControllerConnector {
    associatedtype Parent: UIViewController
    associatedtype Child: UIViewController
    var oneChildViewControllerConnector: DocumentModule.ViewControllers.OneChildViewControllerConnector<Parent, Child> {get}
}

extension DocumentModuleViewControllersHasOneChildViewControllerConnector where Self: UIViewController {
    mutating func configured(childViewController: Child) -> Self {
        var connector = self.oneChildViewControllerConnector
        _ = connector.configured(child: childViewController)
        return self
    }
}

// MARK: OneChildViewControllerConnector
extension FileNamespace {
    struct OneChildViewControllerConnector<Parent: UIViewController, Child: UIViewController> {
        weak var parent: Parent?
        weak var child: Child?
        init(parent: Parent) {
            self.init(parent: parent, child: nil)
        }
        init(parent: Parent?, child: Child?) {
            self.parent = parent
            self.child = child
        }
    }
}

// MARK: OneChildViewControllerConnector / Configurations
extension FileNamespace.OneChildViewControllerConnector {
    mutating func configured(child: Child) -> Self {
        self.child = child
        return self
    }
}

// MARK: OneChildViewControllerConnector / Setup
extension FileNamespace.OneChildViewControllerConnector {
    func setupUIElements() {
        if let child = self.child, let parent = self.parent {
            parent.addChild(child)
        }
    }
    
    func addLayout() {
        if let view = self.child?.view, let parent = self.parent {
            parent.view.addSubview(view)
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
    
    func onViewDidLoad() {
        self.setupUIElements()
        self.addLayout()
        self.child?.didMove(toParent: self.parent)
    }
}

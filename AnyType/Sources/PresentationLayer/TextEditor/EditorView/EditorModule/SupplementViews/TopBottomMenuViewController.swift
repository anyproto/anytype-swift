import Foundation
import UIKit


class TopBottomMenuViewController: UIViewController {
    private let animationDuration: TimeInterval = 0.3
    /// Views
    private var topView: UIStackView = .init()
    private var containerView: UIView = .init()
    private var bottomView: UIStackView = .init()
    
    private var childViewController: UIViewController?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
        self.updateChildViewController()
    }

    // MARK: Setup and Layout
    func setupUIElements() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.topView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            return view
        }()
        self.containerView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        self.bottomView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            return view
        }()
        self.view.addSubview(self.topView)
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.bottomView)
    }
    
    func addLayout() {
        if let superview = self.topView.superview {
            let view = self.topView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        if let superview = self.containerView.superview {
            let view = self.containerView
            let topView = self.topView
            let bottomView = self.bottomView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: topView.bottomAnchor),
                view.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        if let superview = self.bottomView.superview {
            let view = self.bottomView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func updateChildViewController() {        
        if let viewController = self.childViewController {
            self.addChild(viewController)
        }
        
        if let view = self.childViewController?.view {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(view)
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
        self.didMove(toParent: self.childViewController)
    }
}

extension TopBottomMenuViewController {
    enum Kind {
        case top
        case bottom
    }
}

// MARK: Check state
extension TopBottomMenuViewController {
    enum MenusState {
        case none
        case hasTop
        case hasBottom
        case hasBoth
    }
    func menusState() -> MenusState {
        switch (topView.arrangedSubviews.isEmpty, bottomView.arrangedSubviews.isEmpty) {
        case (true, true): return .none
        case (true, false): return .hasTop
        case (false, true): return .hasBottom
        case (false, false): return .hasBoth
        }
    }
}

// MARK: Toolbar Manipulations
extension TopBottomMenuViewController {
    func toolbarView(by kind: Kind) -> UIStackView {
        switch kind {
        case .top: return self.topView
        case .bottom: return self.bottomView
        }
    }
    
    func add(subview: UIView?, onToolbar kind: Kind) {
        self._add(subview: subview, onToolbar: kind)
        UIView.animate(withDuration: animationDuration) {
            self.toolbarView(by: kind).arrangedSubviews.first?.isHidden = false
            self.toolbarView(by: kind).layoutIfNeeded()
        }
    }
    
    private func _add(subview: UIView?, onToolbar kind: Kind) {
        if let view = subview {
            let toolbarView = self.toolbarView(by: kind)
            toolbarView.addArrangedSubview(view)
            toolbarView.layoutIfNeeded()
            view.layoutIfNeeded()
            view.isHidden = true
        }
    }
    
    func removeSubview(fromToolbar kind: Kind) {
        let  toolbar = toolbarView(by: kind)
        
        toolbar.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, animations: {
            toolbar.arrangedSubviews.first.flatMap {
                $0.isHidden = true
            }
            toolbar.layoutIfNeeded()
        }) { (value) in
            toolbar.subviews.forEach { (value) in
                value.removeFromSuperview()
            }
        }
    }

    // MARK: Add Child
    func add(child controller: UIViewController?) {
        self.childViewController = controller
    }
}

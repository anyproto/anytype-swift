import Foundation
import UIKit


class BottomMenuViewController: UIViewController {
    private let animationDuration: TimeInterval = 0.3
    
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
    private func setupUIElements() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
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
        self.view.addSubview(self.containerView)
        self.view.addSubview(self.bottomView)
    }
    
    private func addLayout() {
        if let superview = self.containerView.superview {
            let view = self.containerView
            let bottomView = self.bottomView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
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

extension BottomMenuViewController {
    enum MenusState {
        case none
        case hasBottom
    }
    
    func menusState() -> MenusState {
        switch (bottomView.arrangedSubviews.isEmpty) {
        case (true): return .none
        case (false): return .hasBottom
        }
    }
}

// MARK: Toolbar Manipulations
extension BottomMenuViewController {
    func addBottomView(_ view: UIView) {
        bottomView.addArrangedSubview(view)
        bottomView.layoutIfNeeded()
        view.layoutIfNeeded()
        view.isHidden = true
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.bottomView.arrangedSubviews.first?.isHidden = false
            self?.bottomView.layoutIfNeeded()
        }
    }
    
    func removeBottomView() {
        bottomView.setNeedsLayout()
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.bottomView.arrangedSubviews.first.flatMap {
                $0.isHidden = true
            }
            self?.bottomView.layoutIfNeeded()
        }) { [weak self] (value) in
            self?.bottomView.subviews.forEach { (value) in
                value.removeFromSuperview()
            }
        }
    }

    // MARK: Add Child
    func add(child controller: UIViewController?) {
        self.childViewController = controller
    }
}

import Foundation
import UIKit

final class BottomMenuViewController: UIViewController {
    private let animationDuration: TimeInterval = 0.3
    
    private var containerView = UIView()
    
    private var bottomView = UIView()
    private var bottomViewBottomConstraint = NSLayoutConstraint()
    private let bottomViewHeight: CGFloat = 48
    
    private var childViewController: UIViewController?

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildViewController()
        addLayout()
    }

}

extension BottomMenuViewController {
    
    enum MenusState {
        case none
        case hasBottom
    }
    
    func menusState() -> MenusState {
        bottomView.subviews.isEmpty ? .none : .hasBottom
    }
    
}

// MARK: Toolbar Manipulations
extension BottomMenuViewController {
    
    func addBottomView(_ view: UIView) {
        bottomView.addSubview(view)
        view.pinAllEdges(to: bottomView)
        self.view.layoutIfNeeded()

        bottomViewBottomConstraint.constant = -self.view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func removeBottomView() {
        bottomViewBottomConstraint.constant = bottomViewHeight
        
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.bottomView.subviews.forEach { $0.removeFromSuperview() }
        }
    }

    // MARK: Add Child
    func add(child controller: UIViewController?) {
        self.childViewController = controller
    }
    
}

private extension BottomMenuViewController {
    
    func setupChildViewController() {
        guard let childViewController = childViewController else { return }
        
        embedChild(childViewController, into: containerView)
        childViewController.view.pinAllEdges(to: containerView)
    }

    func addLayout() {
        view.addSubview(containerView)
        view.addSubview(bottomView)
        
        containerView.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomView.topAnchor)
        }
        
        bottomView.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.top, .bottom])
            bottomViewBottomConstraint = $0.bottom.equal(
                to: view.bottomAnchor,
                constant: bottomViewHeight
            )
            $0.height.equal(to: bottomViewHeight)
        }
    }
    
}

import Foundation
import UIKit


class BottomMenuViewController: UIViewController {
    private let animationDuration: TimeInterval = 0.3
    
    private var containerView = UIView()
    
    private var bottomView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    private var childViewController: UIViewController?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLayout()
        updateChildViewController()
    }

    private func addLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(containerView)
        self.view.addSubview(bottomView)
        
        containerView.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.bottom])
            $0.bottom.equal(to: bottomView.topAnchor)
        }
        
        bottomView.layoutUsing.anchors {
            $0.pinToSuperview(excluding: [.top])
        }
    }
        
    func updateChildViewController() {
        if let viewController = self.childViewController {
            self.addChild(viewController)
        }
        
        if let view = self.childViewController?.view {
            containerView.addSubview(view)
            view.pinAllEdges(to: containerView)
        }
        
        childViewController?.didMove(toParent: self)
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

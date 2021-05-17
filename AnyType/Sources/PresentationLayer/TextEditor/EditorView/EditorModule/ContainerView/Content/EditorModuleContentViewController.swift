import Foundation
import UIKit
import Combine

class EditorModuleContentViewController: UIViewController {
    
    private var viewModel: EditorModuleContentViewModel
    private var childViewController: UIViewController?
    
    init(
        viewModel: EditorModuleContentViewModel,
        childViewController: UIViewController
    ) {
        self.viewModel = viewModel
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup And Layout
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

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
        self.didMove(toParent: self.childViewController)
    }
}

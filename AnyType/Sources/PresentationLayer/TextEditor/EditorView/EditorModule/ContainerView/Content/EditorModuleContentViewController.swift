import Foundation
import UIKit
import Combine

class EditorModuleContentViewController: UIViewController {
    
    private let childViewController: UIViewController
    
    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup And Layout
    func addLayout() {
        self.addChild(childViewController)
        
        self.view.addSubview(childViewController.view)
        childViewController.view.pinAllEdges(to: self.view)
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        childViewController.didMove(toParent: self)
    }
}

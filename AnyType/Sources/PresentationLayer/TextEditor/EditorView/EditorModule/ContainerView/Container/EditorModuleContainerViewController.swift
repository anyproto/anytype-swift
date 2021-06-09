import Foundation
import UIKit
import Combine

final class EditorModuleContainerViewController: UIViewController {
    
    // MARK: - Private variables
    
    private var viewModel: EditorModuleContainerViewModel
    private let childViewController: UIViewController
    private var subscription: AnyCancellable?
    private var toRemove: AnyCancellable?
          
    // MARK: - Initializers
    
    init(
        viewModel: EditorModuleContainerViewModel,
        childViewController: UIViewController
    ) {
        self.viewModel = viewModel
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrided functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        embedChild(childViewController)
        childViewController.view.pinAllEdges(to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.shadowColor = nil
        
        windowHolder?.modifyNavigationBarAppearance(navBarAppearance)
    }

}

// MARK: - Private extension

private extension EditorModuleContainerViewController {
    
    func setup() {
        subscription = viewModel.actionPublisher()
            .sink { [weak self] value in
                self?.handle(value)
            }
    }
    
    func handle(_ action: EditorModuleContainerViewModel.Action) {
        switch action {
        case let .child(value):
            windowHolder?.rootNavigationController.pushViewController(value, animated: true)
        case let .show(value):
            present(value, animated: true, completion: nil)
        case .pop:
            windowHolder?.rootNavigationController.popViewController(animated: true)
        case let .childDocument(value):
            handle(.child(value.viewController))
        case let .showDocument(value):
            handle(.show(value.viewController))
        }
    }
}

import Foundation
import UIKit
import Combine

/// We use `TransitionViewController` as a view controller for custom transitions.
/// Also, this controller could contain/store all presentation and dismissal animators.
/// Very handy.
///
typealias TransitionViewController = CommonViews.ViewControllers.TransitionContainerViewController

final class EditorModuleContainerViewController: UIViewController {
    
    // MARK: - Private variables
    
    private let transitionContainer = TransitionViewController()
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
        configuredTransitioning()
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

// MARK: UINavigationController Handling

extension EditorModuleContainerViewController: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard
            let controller = viewController.children.first?.children.first as? BottomMenuViewController,
            let editor = controller.children.first as? DocumentEditorViewController
        else {
            return
        }
        
        // Tell our view model about update
        viewModel.configured(
            userActionsStream: editor.getViewModel().publicUserActionPublisher
        )
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

// MARK: Setup And Layout
private extension EditorModuleContainerViewController {
    
    typealias TransitionController = MarksPane.ViewController.TransitionController
    
    func configuredTransitioning() {
        let presentation: TransitionController? = .init()
        let dismissal: TransitionController? = .init()
        _ = dismissal?.configured(transitionDirection: .backward)
        _ = presentation?.configured(presentedViewController: self)
        let containerController = self.transitionContainer
        _ = containerController//.configured(root: self)
            .configured(presentationAnimator: presentation)
            .configured(presentationInteractor: presentation)
            .configured(dismissalAnimator: dismissal)
            .configured(dismissalInteractor: dismissal)
        self.transitioningDelegate = containerController
        self.modalPresentationStyle = .custom
    }
}

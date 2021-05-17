import Foundation
import UIKit
import Combine

/// We use `TransitionViewController` as a view controller for custom transitions.
/// Also, this controller could contain/store all presentation and dismissal animators.
/// Very handy.
///
typealias TransitionViewController = CommonViews.ViewControllers.TransitionContainerViewController
class EditorModuleContainerViewController: UIViewController {
    
    private var userActionSubject: PassthroughSubject<UserAction, Never> = .init()
    var userActionPublisher: AnyPublisher<UserAction, Never> = .empty()
    
    private var transitionContainer: TransitionViewController = .init()
    private var viewModel: EditorModuleContainerViewModel
    private let childViewController: UIViewController
    private var subscription: AnyCancellable?
    private var toRemove: AnyCancellable?
    private var childAsNavigationController: UINavigationController? {
        self.childViewController as? UINavigationController
    }
    
    func setup() {
        self.subscription = viewModel.actionPublisher().sink { [weak self] (value) in
            self?.handle(value)
        }
        
        self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
    }
            
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

    // MARK: Actions Handling
    func handle(_ action: EditorModuleContainerViewModel.Action) {
        switch action {
        case let .child(value): self.childAsNavigationController?.pushViewController(value, animated: true)
        case let .show(value): self.present(value, animated: true, completion: nil)
        case .pop: self.childAsNavigationController?.popViewController(animated: true)
        case let .childDocument(value):
            let viewModel = value.viewModel
            let viewController = value.viewController
            viewModel.configured(navigationItem: viewController.navigationItem)
            self.handle(.child(value.viewController))
        case let .showDocument(value):
            let viewModel = value.viewModel
            let viewController = value.viewController
            viewModel.configured(navigationItem: viewController.navigationItem)
            self.handle(.show(value.viewController))
        }
    }
}

// MARK: UINavigationController Handling
extension EditorModuleContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        /// We should keep track of navigation links.
        /// Where we should update navigation from item.
        if let controller = viewController as? EditorModuleContentViewController {
            
            if let child = controller.children.first?.children.first as? DocumentEditorViewController {
                /// extract model from it.
                let viewModel = child.getViewModel()
                
                /// Tell our view model about update
                _ = self.viewModel.configured(userActionsStream: viewModel.publicUserActionPublisher)
            }
            
        }
    }
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? EditorModuleContentViewController {
            
            if controller.children.first?.children.first as? DocumentEditorViewController != nil {
                /// extract model from it.
            }
        }
    }
}

// MARK: Setup And Layout
private extension EditorModuleContainerViewController {
    func setupUIElements() {
        self.addChild(childViewController)
    }
    
    func addLayout() {
        if let view = self.childViewController.view {
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

// MARK: Transitioning
extension EditorModuleContainerViewController {
    typealias TransitionController = MarksPane.ViewController.TransitionController
}

// MARK: User Actions
extension EditorModuleContainerViewController {
    enum UserAction {
        case shouldDismiss
    }
}

// MARK: Actions
extension EditorModuleContainerViewController {
    @objc func dismissAction() {
        self.userActionSubject.send(.shouldDismiss)
    }
}

// MARK: Gesture Recognizer
extension EditorModuleContainerViewController {
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
extension EditorModuleContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUIElements()
        self.addLayout()
        self.didMove(toParent: self.childViewController)
        self.configuredTransitioning()
    }
}

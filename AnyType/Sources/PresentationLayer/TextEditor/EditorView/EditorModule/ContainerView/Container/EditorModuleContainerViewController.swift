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
            let viewController = value.viewController
            value.selectionPresenter.navigationItem = viewController.navigationItem
            self.handle(.child(value.viewController))
        case let .showDocument(value):
            let viewController = value.viewController
            value.selectionPresenter.navigationItem = viewController.navigationItem
            self.handle(.show(value.viewController))
        }
    }
}

// MARK: UINavigationController Handling
extension EditorModuleContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        guard let controller = viewController as? BottomMenuViewController,
              let editor = controller.children.first as? DocumentEditorViewController  else {
            assertionFailure("DocumentEditorViewController not found as a child of BottomMenuViewController")
            return
        }

        // Tell our view model about update
        viewModel.configured(userActionsStream: editor.getViewModel().publicUserActionPublisher)
    }
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
}

// MARK: Setup And Layout
private extension EditorModuleContainerViewController {
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
        embedChild(childViewController)
        configuredTransitioning()
    }
}

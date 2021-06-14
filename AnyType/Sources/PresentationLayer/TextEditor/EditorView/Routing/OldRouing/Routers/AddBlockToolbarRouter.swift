import UIKit

class AddBlockToolbarRouter {
    /// Custom UINavigationBar for AddBlock toolbar.
    ///
    private class NavigationBar: UINavigationBar {}
    
    private weak var baseViewController: UIViewController?
    init(baseViewController: UIViewController?) {
        self.baseViewController = baseViewController
    }
            
    func handle(payload: BlockUserAction.AddBlock) {
        let viewModel = BlocksViews.Toolbar.ViewController.ViewModel(.init(style: .addBlock))
        let controller = BlocksViews.Toolbar.ViewController.init(model: viewModel)
        
        let subject = payload.output
        
        /// NOTE: Tough point.
        /// We have a view model here.
        /// It could publish action, suppose, it is `.$action` publisher.
        /// Next, we would like to send events to a subject that is coming in associated value.
        /// Again, somebody need to keep this subscription.
        /// In our case, we choose viewModel.
        ///
        /// ViewModel.action -> Publish Action.
        /// Subject <- Published Action.
        /// ViewModel.subscription = subject.send(ViewModel.action.publishedValue)
        viewModel.subscribe(subject: subject, keyPath: \.action)
        
        // TODO: Rethink.
        // Should we configure appearance of controller here?
        let appearance = NavigationBar.appearance()
        appearance.tintColor = .grayscale90
        appearance.backgroundColor = .white
        appearance.isTranslucent = false
        let viewController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        viewController.viewControllers = [controller]
        baseViewController?.present(viewController, animated: true, completion: nil)
    }
}

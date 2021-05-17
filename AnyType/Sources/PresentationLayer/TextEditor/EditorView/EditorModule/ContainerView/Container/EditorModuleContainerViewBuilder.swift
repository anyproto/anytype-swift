import Foundation
import UIKit
import SwiftUI


enum EditorModuleContainerViewBuilder {
    typealias ChildViewModel = EditorModuleContentViewModel
    typealias ChildViewController = EditorModuleContentViewController
    typealias ChildViewBuilder = EditorModuleContentViewBuilder
    
    typealias ChildComponent = ChildViewBuilder.SelfComponent
    typealias SelfComponent = (viewController: EditorModuleContainerViewController, viewModel: EditorModuleContainerViewModel, childComponent: ChildComponent)
    
    static func view(id: String) -> EditorModuleContainerViewController {
        self.selfComponent(id: id).0
    }
    
    /// Returns `ChildComponent` for request in concrete builder. It uses `ChildViewBuilder.UIKitBuilder.selfComponent(by:)` method.
    /// For us `childComponent` is a `selfComponent` of `ChildViewBuilder` or `ChildViewBuilder.UIKitBuilder.selfComponent(by:)`
    /// - Parameter request: A request for which we will build child component.
    /// - Returns: A child component for a request.
    ///
    static func childComponent(id: String) -> ChildComponent {
        ChildViewBuilder.selfComponent(id: id)
    }
    
    /// Return `SelfComponent` for request in concrete builder.
    /// For us `selfComponent` is a target for this builder. It access childComponent to configure it by entities on this level.
    ///
    /// For example, if you want connect user actions which are coming from internal view, you need access to it on level of builder.
    /// It will be `childComponent` or `childChildComponent` ( a.k.a. `ChildViewBuilder.UIKitBuilder.ChildComponent` )
    ///
    /// - Parameter request: A request for which we will build self component.
    /// - Returns: A self component for a request.
    ///
    private static func selfComponent(id: String) -> SelfComponent {
        let childComponent = self.childComponent(id: id)
        
        let childViewController = childComponent.0
        
        /// Configure Navigation Controller
        let navigationController = UINavigationController(navigationBarClass: EditorModuleContainerViewBuilder.NavigationBar.self, toolbarClass: nil)
        NavigationBar.applyAppearance()
        navigationController.setViewControllers([childViewController], animated: false)
        navigationController.navigationBar.isTranslucent = false
        
        /// Configure Navigation Item for Content View Model.
        /// We need it to support Selection navigation bar buttons.
        let childViewModel = childComponent.1
        _ = childViewModel.configured(navigationItem: childViewController.navigationItem)
        
        let childChildComponent = childComponent.2
        let childChildViewModel = childChildComponent.1
        
        /// Don't forget configure router by events from blocks.
        let router: DocumentViewRouting.CompoundRouter = .init()
        _ = router.configured(userActionsStream: childChildViewModel.publicUserActionPublisher)
        
        /// Configure ViewModel of current View Controller.
        let viewModel = EditorModuleContainerViewModel()
        _ = viewModel.configured(router: router)
        
        /// Configure current ViewController.
        let viewController = EditorModuleContainerViewController(viewModel: viewModel)
        _ = viewController.configured(childViewController: navigationController)
        
        /// Configure navigation item of root
        let backButtonImage = UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        childViewController.navigationItem.leftBarButtonItem = .init(image: backButtonImage, style: .plain, target: viewController, action: #selector(viewController.dismissAction))

        /// DEBUG: Conformance to navigation delegate.
        ///
        navigationController.delegate = viewController
        
        return (viewController, viewModel, childComponent)
    }
}

// MARK: Custom Appearance
/// TODO: Move it somewhere
private extension EditorModuleContainerViewBuilder {
    class NavigationBar: UINavigationBar {
        static func applyAppearance() {
            let appearance = Self.appearance()
            appearance.prefersLargeTitles = false
            appearance.tintColor = .gray
            appearance.backgroundColor = .white
        }
    }
}

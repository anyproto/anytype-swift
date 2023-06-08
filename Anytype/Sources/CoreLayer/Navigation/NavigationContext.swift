import Foundation
import UIKit
import SwiftUI

protocol NavigationContextProtocol: AnyObject {
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) -> AnytypeDismiss
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?)
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?)
    func push(_ viewControllerToPresent: UIViewController, animated: Bool)
}

extension NavigationContextProtocol {
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> AnytypeDismiss {
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func dismissTopPresented(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismissTopPresented(animated: animated, completion: completion)
    }
    
    func dismissAllPresented(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismissAllPresented(animated: animated, completion: completion)
    }
    
    func presentSwiftUIView<Content: View>(view: Content, model: Dismissible? = nil, animated: Bool = true) {
        present(view, model: model, animated: animated)
    }
    
    func present<Content: View>(_ view: Content, model: Dismissible? = nil, animated: Bool = true) {
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        present(controller, animated: animated)
    }
    
    func push(_ viewControllerToPresent: UIViewController) {
        push(viewControllerToPresent, animated: true)
    }
    
    func push<Content: View>(_ view: Content) {
        let controller = UIHostingController(rootView: view)
        push(controller, animated: true)
    }
}

final class NavigationContext: NavigationContextProtocol {
    
    private var rootViewControllerProvider: () -> UIViewController?
    
    convenience init(window: UIWindow?) {
        self.init(rootViewControllerProvider: { [weak window] in
            return window?.rootViewController
        })
    }
    
    convenience init(rootViewController: UIViewController?) {
        self.init(rootViewControllerProvider: { [weak rootViewController] in
            return rootViewController
        })
    }
    
    private init(rootViewControllerProvider: @escaping () -> UIViewController?) {
        self.rootViewControllerProvider = rootViewControllerProvider
    }
    
    // MARK: - NavigationContextProtocol
    
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) -> AnytypeDismiss {
        guard let viewController = rootViewControllerProvider()?.topPresentedController else {
            return AnytypeDismiss(dismiss: {})
        }
        
        viewController.present(viewControllerToPresent, animated: animated, completion: completion)
        
        return AnytypeDismiss { [weak viewControllerToPresent] in
            guard let presenting = viewControllerToPresent?.presentingViewController else {
                return
            }
            
            presenting.dismiss(animated: animated)
        }
    }
    
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?) {
        guard let viewController = rootViewControllerProvider()?.topPresentedController else {
            return
        }
        
        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?) {
        guard let viewController = rootViewControllerProvider() else {
            return
        }
            
        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func push(_ viewControllerToPresent: UIViewController, animated: Bool) {
        guard let viewController = rootViewControllerProvider()?.topPresentedController as? UINavigationController else {
            return
        }
            
        viewController.pushViewController(viewControllerToPresent, animated: animated)
    }
}

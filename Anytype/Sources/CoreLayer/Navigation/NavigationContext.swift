import Foundation
import UIKit
import SwiftUI

protocol NavigationContextProtocol: AnyObject {
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?)
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?)
    func push(_ viewControllerToPresent: UIViewController, animated: Bool)
}

extension NavigationContextProtocol {
    func present(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func dismissTopPresented(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismissTopPresented(animated: animated, completion: completion)
    }
    
    func dismissAllPresented(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismissAllPresented(animated: animated, completion: completion)
    }
    
    func presentSwiftUIView<Content: View>(view: Content, model: Dismissible? = nil, animated: Bool = true) {
        let controller = UIHostingController(rootView: view)
        model?.onDismiss = { [weak controller] in controller?.dismiss(animated: true) }
        present(controller, animated: animated)
    }
    
    func push(_ viewControllerToPresent: UIViewController) {
        push(viewControllerToPresent, animated: true)
    }
}

final class NavigationContext: NavigationContextProtocol {
    
    private var rootViewControllerProvider: () -> UIViewController?
    
    private static let queue = DispatchQueue(label: "com.anytype.navigation", qos: .userInteractive)
    private static let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
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
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        addOperationToQueue { [weak self] completeCall in
                
            guard let viewController = self?.rootViewControllerProvider()?.topPresentedController else {
                completeCall()
                return
            }
            
            viewController.present(viewControllerToPresent, animated: animated) {
                completeCall()
                completion?()
            }
        }
    }
    
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?) {
        addOperationToQueue { [weak self] completeCall in
            
            guard let viewController = self?.rootViewControllerProvider()?.topPresentedController else {
                completeCall()
                return
            }
            
            viewController.dismiss(animated: animated) {
                completeCall()
                completion?()
            }
        }
    }
    
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?) {
        addOperationToQueue { [weak self] completeCall in
            
            guard let viewController = self?.rootViewControllerProvider() else {
                completeCall()
                return
            }
            
            viewController.dismiss(animated: animated) {
                completeCall()
                completion?()
            }
        }
    }
    
    func push(_ viewControllerToPresent: UIViewController, animated: Bool) {
        addOperationToQueue { [weak self] completeCall in
            guard let viewController = self?.rootViewControllerProvider()?.topPresentedController as? UINavigationController else {
                completeCall()
                return
            }
            
            viewController.pushViewController(viewControllerToPresent, animated: animated)
            completeCall()
        }
    }
         
    // MARK: - Private
    
    private func addOperationToQueue(_ operation: @escaping (_ completeCall: @escaping () -> ()) -> Void) {
        NavigationContext.queue.async {
            NavigationContext.semaphore.wait()
            
            DispatchQueue.main.async {
                
                operation {
                    NavigationContext.semaphore.signal()
                }
            }
        }
    }
}

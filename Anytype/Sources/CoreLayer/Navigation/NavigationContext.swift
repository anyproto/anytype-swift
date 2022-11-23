import Foundation
import UIKit
import SwiftUI

protocol NavigationContextProtocol {
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?)
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?)
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
}

final class NavigationContext: NavigationContextProtocol {
    
    private weak var rootViewController: UIViewController?
    
    private static let queue = DispatchQueue(label: "com.anytype.navigation", qos: .userInteractive)
    private static let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    init(rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        addOperationToQueue { [weak self] completeCall in
                
            guard let viewController = self?.rootViewController?.topPresentedController else {
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
            
            guard let viewController = self?.rootViewController?.topPresentedController else {
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
            
            guard let viewController = self?.rootViewController else {
                completeCall()
                return
            }
            
            viewController.dismiss(animated: animated) {
                completeCall()
                completion?()
            }
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

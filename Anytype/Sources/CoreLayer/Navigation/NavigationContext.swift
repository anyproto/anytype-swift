import Foundation
import UIKit
import SwiftUI


@MainActor
protocol NavigationContextProtocol: AnyObject {
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) -> AnytypeDismiss
    func dismissTopPresented(animated: Bool, completion: (() -> Void)?)
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?)
    func push(_ viewControllerToPresent: UIViewController, animated: Bool)
    func pop(animated: Bool)
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
    
    func presentSwiftUIView<Content: View>(view: Content, animated: Bool = true) {
        present(view, animated: animated)
    }
    
    func present<Content: View>(
        _ view: Content,
        modalPresentationStyle: UIModalPresentationStyle? = nil,
        mediumDetent: Bool = false,
        animated: Bool = true,
        completion: (() -> Void)? = nil)
    {
        let controller = UIHostingController(rootView: view)
        
        if let modalPresentationStyle {
            controller.modalPresentationStyle = modalPresentationStyle
        }
        if mediumDetent, let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
        }
        
        present(controller, animated: animated, completion: completion)
    }
    
    func push(_ viewControllerToPresent: UIViewController) {
        push(viewControllerToPresent, animated: true)
    }
    
    func push<Content: View>(_ view: Content) {
        let controller = UIHostingController(rootView: view)
        push(controller, animated: true)
    }
}

@MainActor
final class NavigationContext: NavigationContextProtocol {
    
    @Injected(\.legacyViewControllerProvider)
    private var viewControllerProvider: any ViewControllerProviderProtocol
    
    private var navigationController: UINavigationController? {
        viewControllerProvider.rootViewController?.topPresentedController as? UINavigationController
    }
    
    nonisolated init() {}
    
    // MARK: - NavigationContextProtocol
    
    @discardableResult
    func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) -> AnytypeDismiss {
        guard let viewController = viewControllerProvider.rootViewController?.topPresentedController else {
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
        guard let viewController = viewControllerProvider.rootViewController?.topPresentedController else {
            return
        }
        
        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func dismissAllPresented(animated: Bool, completion: (() -> Void)?) {
        guard let viewController = viewControllerProvider.rootViewController else {
            return
        }
            
        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func push(_ viewControllerToPresent: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewControllerToPresent, animated: animated)
    }
    
    func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
}

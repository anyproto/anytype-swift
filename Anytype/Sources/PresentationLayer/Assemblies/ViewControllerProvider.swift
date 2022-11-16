import Foundation
import UIKit

protocol ViewControllerProviderProtocol {
    var window: UIWindow { get }
    var rootViewController: UIViewController? { get }
    var topViewController: UIViewController? { get }
}

final class ViewControllerProvider: ViewControllerProviderProtocol {
    
    private let sceneWindow: UIWindow
    
    init(sceneWindow: UIWindow) {
        self.sceneWindow = sceneWindow
    }
    
    // MARK: - ViewControllerProviderProtocol
    
    var window: UIWindow {
        return sceneWindow
    }
    
    var rootViewController: UIViewController? {
        return sceneWindow.rootViewController
    }
    
    var topViewController: UIViewController? {
        return sceneWindow.rootViewController?.topPresentedController
    }
}

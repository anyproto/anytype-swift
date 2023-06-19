import Foundation
import UIKit

protocol ViewControllerProviderProtocol {
    var window: UIWindow? { get }
    var rootViewController: UIViewController? { get }
    var topVisibleController: UIViewController? { get }
}

final class ViewControllerProvider: ViewControllerProviderProtocol {
    
    private weak var sceneWindow: UIWindow?
    
    init(sceneWindow: UIWindow) {
        self.sceneWindow = sceneWindow
    }
    
    // MARK: - ViewControllerProviderProtocol
    
    var window: UIWindow? {
        return sceneWindow
    }
    
    var rootViewController: UIViewController? {
        return sceneWindow?.rootViewController
    }
    
    var topVisibleController: UIViewController? {
        return sceneWindow?.rootViewController?.topVisibleController
    }
}

import Foundation
import UIKit

@MainActor
protocol ViewControllerProviderProtocol {
    var window: UIWindow? { get }
    var rootViewController: UIViewController? { get }
    var topVisibleController: UIViewController? { get }
    func setSceneWindow(_ sceneWindow: UIWindow?)
}

@MainActor
final class ViewControllerProvider: ViewControllerProviderProtocol {
    
    private weak var sceneWindow: UIWindow?
        
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
    
    func setSceneWindow(_ sceneWindow: UIWindow?) {
        self.sceneWindow = sceneWindow
    }
}

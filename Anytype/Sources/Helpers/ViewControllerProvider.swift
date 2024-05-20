import Foundation
import UIKit

protocol ViewControllerProviderProtocol {
    var window: UIWindow? { get }
    var rootViewController: UIViewController? { get }
    var topVisibleController: UIViewController? { get }
}

final class ViewControllerProvider: ViewControllerProviderProtocol {
    
    weak var sceneWindow: UIWindow?
    
    static let shared = ViewControllerProvider()
    
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

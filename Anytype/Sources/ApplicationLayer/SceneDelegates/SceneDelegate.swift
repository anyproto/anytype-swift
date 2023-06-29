import UIKit
import SwiftUI
import AnytypeCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var di: DIProtocol?
    private var applicationCoordinator: ApplicationCoordinatorProtocol?
    
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        connectionOptions.shortcutItem.flatMap { _ = handleQuickAction($0) }
        let window = AnytypeWindow(windowScene: windowScene)
        self.window = window
        
        let viewControllerProvider = ViewControllerProvider(sceneWindow: window)
        let di: DIProtocol = DI(viewControllerProvider: viewControllerProvider)
        self.di = di
        
        let applicationCoordinator = di.coordinatorsDI.application().make()
        self.applicationCoordinator = applicationCoordinator
        
        applicationCoordinator.start(connectionOptions: connectionOptions)

        window.overrideUserInterfaceStyle = UserDefaultsConfig.userInterfaceStyle
        
        ToastPresenter.shared = ToastPresenter(
            viewControllerProvider: ViewControllerProvider(sceneWindow: window),
            keyboardHeightListener: KeyboardHeightListener()
        )
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURLContext(openURLContexts: URLContexts)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.shortcutItems = QuickAction.allCases.map { $0.shortcut }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: item.type) else {
            anytypeAssertionFailure("Not supported action", info: ["action": item.type])
            return false
        }
        
        DispatchQueue.main.async { QuickActionsStorage.shared.action = action }
        return true
    }

    private func handleURLContext(openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard URLContexts.count == 1, let context = URLContexts.first else {
            return
        }

        applicationCoordinator?.handleDeeplink(url: context.url)
    }
}

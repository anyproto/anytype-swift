import UIKit
import SwiftUI
import AnytypeCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var di: DIProtocol?
    private let sceneDelegates: [UIWindowSceneDelegate] = [LifecycleStateTransitionSceneDelegate()]
    private var applicationCoordinator: ApplicationCoordinator?
    
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
        
        let applicationCoordinator = di.coordinatorsDI.application()
        self.applicationCoordinator = applicationCoordinator
        
        applicationCoordinator.start(connectionOptions: connectionOptions)

        window.overrideUserInterfaceStyle = UserDefaultsConfig.userInterfaceStyle
        
        ToastPresenter.shared = ToastPresenter(
            viewControllerProvider: ViewControllerProvider(sceneWindow: window),
            keyboardHeightListener: KeyboardHeightListener()
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        sceneDelegates.forEach {
            $0.sceneDidDisconnect?(scene)
        }
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURLContext(openURLContexts: URLContexts)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        sceneDelegates.forEach {
            $0.sceneDidBecomeActive?(scene)
        }
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        sceneDelegates.forEach {
            $0.sceneWillResignActive?(scene)
        }
        UIApplication.shared.shortcutItems = QuickAction.allCases.map { $0.shortcut }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        sceneDelegates.forEach {
            $0.sceneWillEnterForeground?(scene)
        }
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        sceneDelegates.forEach {
            $0.sceneDidEnterBackground?(scene)
        }
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: item.type) else {
            anytypeAssertionFailure("Not supported action: \(item.type)", domain: .quickAction)
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

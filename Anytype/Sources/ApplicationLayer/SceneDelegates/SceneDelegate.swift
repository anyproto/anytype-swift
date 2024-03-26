import UIKit
import SwiftUI
import AnytypeCore
import DeepLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var di: DIProtocol?
    private var deepLinkParser: DeepLinkParserProtocol?

    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = AnytypeWindow(windowScene: windowScene)
        self.window = window
        
        let viewControllerProvider = ViewControllerProvider(sceneWindow: window)
        let di: DIProtocol = DI(viewControllerProvider: viewControllerProvider)
        self.di = di
        deepLinkParser = di.serviceLocator.deepLinkParser()
        
        connectionOptions.shortcutItem.flatMap { _ = handleQuickAction($0) }
        handleURLContext(openURLContexts: connectionOptions.urlContexts)
        
        
        let applicationView = di.coordinatorsDI.application().makeView()
            .setKeyboardDismissEnv(window: window)
            .setPresentedDismissEnv(window: window)
        window.rootViewController = UIHostingController(rootView: applicationView)
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = UserDefaultsConfig.userInterfaceStyle
        
        ToastPresenter.shared = ToastPresenter(
            viewControllerProvider: ViewControllerProvider(sceneWindow: window),
            keyboardHeightListener: KeyboardHeightListener(),
            documentsProvider: di.serviceLocator.documentsProvider
        )
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURLContext(openURLContexts: URLContexts)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        let builder = di?.serviceLocator.quickActionShortcutBuilder()
        UIApplication.shared.shortcutItems = builder?.buildShortcutItems()
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        let quickActionShortcutBuilder = di?.serviceLocator.quickActionShortcutBuilder()
        guard let action = quickActionShortcutBuilder?.buildAction(shortcutItem: item) else { return false }
        
        appActionStorage.action = action.toAppAction()
        return true
    }

    private func handleURLContext(openURLContexts: Set<UIOpenURLContext>) {
        guard openURLContexts.count == 1,
              let context = openURLContexts.first,
              let deepLink = deepLinkParser?.parse(url: context.url)
        else { return }
        
        appActionStorage.action = .deepLink(deepLink)
    }
}

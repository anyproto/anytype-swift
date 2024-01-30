import UIKit
import SwiftUI
import AnytypeCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var di: DIProtocol?
    
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
        
        connectionOptions.shortcutItem.flatMap { _ = handleQuickAction($0) }
        handleURLContext(openURLContexts: connectionOptions.urlContexts)
        handleURL(url: URL(string: "anytype://main/import/?type=experience&source=https%3A%2F%2Fstorage.gallery.any.coop%2Fdata_vault%2Fmanifest.json")!)
        
        let applicationView = di.coordinatorsDI.application().makeView()
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
        let quickActionShortcutBuilder = di?.serviceLocator.quickActionShortcutBuilder()
        UIApplication.shared.shortcutItems = QuickAction.allCases.compactMap { quickActionShortcutBuilder?.buildShortcutItem(action: $0) }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        let quickActionShortcutBuilder = di?.serviceLocator.quickActionShortcutBuilder()
        guard let action = quickActionShortcutBuilder?.buildAction(shortcutItem: item) else { return false }
        
        AppActionStorage.shared.action = action.toAppAction()
        return true
    }

    private func handleURLContext(openURLContexts: Set<UIOpenURLContext>) {
        guard openURLContexts.count == 1, 
                let context = openURLContexts.first else {
            return
        }
        
        handleURL(url: context.url)
    }
    
    private func handleURL(url: URL) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        switch components.url {
        case URLConstants.createObjectURL:
            AppActionStorage.shared.action = .createObject
        case URLConstants.sharingExtenstionURL:
            AppActionStorage.shared.action = .showSharingExtension
        case URLConstants.spaceSelectionURL:
            AppActionStorage.shared.action = .spaceSelection
        case URLConstants.galleryImportURL:
            AppActionStorage.shared.action = .galleryImport
        default:
            break
        }
    }
}

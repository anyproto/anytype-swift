import UIKit
import AnytypeCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let appMetricsTracker = AppMetricsTracker()
    private lazy var configurator = AppConfigurator()
    
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: any QuickActionShortcutBuilderProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.pushNotificationService)
    private var pushNotificationService: any PushNotificationServiceProtocol
    
    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Target contains GODEBUG=asyncpreemptoff=1 for fix debug on device
        // More https://github.com/golang/go/issues/57651
        // Delete GODEBUG after fix issue
        
        // Fix SIGPIPE crashes
        signal(SIGPIPE, SIG_IGN)
        
        configurator.configure()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        // Handle for launch
        if let shortcutItem = options.shortcutItem,
            let action = quickActionShortcutBuilder.buildAction(shortcutItem: shortcutItem) {
            appActionStorage.action = action.toAppAction()
        }
        
        let config = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        pushNotificationService.setToken(data: deviceToken)
    }
}

import UIKit
import AnytypeCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let appMetricsTracker = AppMetricsTracker()
    /// receive events from middleware and broadcast throught notification center
    private lazy var eventListener = MiddlewareEventsListener()
    private lazy var configurator = AppConfigurator()
    
    @Injected(\.accountEventHandler)
    private var accountEventHandler: AccountEventHandlerProtocol
    @Injected(\.fileErrorEventHandler)
    private var fileErrorEventHandler: FileErrorEventHandlerProtocol
    @Injected(\.deviceSceneStateListener)
    private var deviceSceneStateListener: DeviceSceneStateListenerProtocol
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: QuickActionShortcutBuilderProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    
    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Target contains GODEBUG=asyncpreemptoff=1 for fix debug on device
        // More https://github.com/golang/go/issues/57651
        // Delete GODEBUG after fix issue
        
        // Fix SIGPIPE crashes
        signal(SIGPIPE, SIG_IGN)
        
        configurator.configure()
        // Global listeners
        eventListener.startListening()
        accountEventHandler.startSubscription()
        fileErrorEventHandler.startSubscription()
        deviceSceneStateListener.start()
        
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
}

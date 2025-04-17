import UIKit
import AnytypeCore
import FirebaseMessaging

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let appMetricsTracker = AppMetricsTracker()
    private lazy var configurator = AppConfigurator()
    
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: any QuickActionShortcutBuilderProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.appSessionTracker)
    private var appSessionTracker: any AppSessionTrackerProtocol
    @Injected(\.applePushNotificationService)
    private var applePushNotificationService: any ApplePushNotificationServiceProtocol
    
    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Target contains GODEBUG=asyncpreemptoff=1 for fix debug on device
        // More https://github.com/golang/go/issues/57651
        // Delete GODEBUG after fix issue
        
        // Fix SIGPIPE crashes
        signal(SIGPIPE, SIG_IGN)
        
        UNUserNotificationCenter.current().delegate = self
        
        appSessionTracker.startReportSession()
        
        configurator.configure()
        
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
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
    
    // MARK: - RemoteNotifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        applePushNotificationService.setToken(data: deviceToken)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // Handle foreground notifications
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    // MARK: - Termination
    
    func applicationWillTerminate(_ application: UIApplication) {
        appSessionTracker.stopReportSession()
    }

}

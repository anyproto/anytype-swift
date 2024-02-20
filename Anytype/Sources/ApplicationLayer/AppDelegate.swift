import UIKit
import AnytypeCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let appMetricsTracker = AppMetricsTracker()
    /// receive events from middleware and broadcast throught notification center
    private lazy var eventListener = MiddlewareEventsListener()
    private lazy var configurator = AppConfigurator()
    
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
        ServiceLocator.shared.accountEventHandler().startSubscription()
        ServiceLocator.shared.fileErrorEventHandler().startSubscription()
        ServiceLocator.shared.deviceSceneStateListener().start()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

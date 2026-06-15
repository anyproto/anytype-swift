import UIKit
import AnytypeCore
import FirebaseMessaging
import Services
import NotificationsCore
import DeepLinks
#if DEBUG
import Network
#endif


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
    @Injected(\.pushNotificationsRegistrationService)
    private var pushNotificationsRegistrationService: any PushNotificationsRegistrationServiceProtocol
    @Injected(\.notificationsCenterService)
    private var notificationsCenterService: any NotificationsCenterServiceProtocol
    @Injected(\.middlewareShutdownService)
    private var middlewareShutdownService: any MiddlewareShutdownServiceProtocol

    // A push tap that cold starts the app is delivered twice — in scene connection options
    // and in userNotificationCenter(_:didReceive:). Whichever runs first records the request
    // id here so the other skips it.
    private var handledPushRequestId: String?

    func application(
        _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        #if DEBUG
        // Xcode 26 beta 2 - fix crash for URLSessions.shared
        // https://developer.apple.com/forums/thread/787365?page=1#842851022
        // https://github.com/firebase/firebase-ios-sdk/issues/14948#issuecomment-2960860573
        _ = nw_tls_create_options()
        #endif
        
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

        // Push tap on cold start: store the deeplink synchronously, before any SwiftUI task runs,
        // so the space id is guaranteed to be available when AccountSelect picks the preferred space
        if FeatureFlags.preferredSpaceOnColdStart,
           let response = options.notificationResponse,
           let deepLink = pushDeepLink(from: response),
           handledPushRequestId != response.notification.request.identifier {
            handledPushRequestId = response.notification.request.identifier
            AnytypeAnalytics.instance().logOpenChatByPush()
            appActionStorage.action = .deepLink(deepLink, .internal)
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
        pushNotificationsRegistrationService.registerForPushNotifications()
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        guard let groupId = userInfo[PushNotificationKeys.groupId] as? String else {
            completionHandler(.noData)
            return
        }
        notificationsCenterService.removeDeliveredNotifications(groupId: groupId)
        completionHandler(.newData)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // Handle foreground notifications
        if FeatureFlags.showPushMessagesInForeground {
            completionHandler([.banner, .list, .sound, .badge])
        } else {
            completionHandler([])
        }
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        if let deepLink = pushDeepLink(from: response) {
            let requestId = response.notification.request.identifier
            Task { @MainActor in
                guard handledPushRequestId != requestId else { return }
                handledPushRequestId = requestId
                AnytypeAnalytics.instance().logOpenChatByPush()
                appActionStorage.action = .deepLink(deepLink, .internal)
            }
        }

        completionHandler()
    }

    nonisolated private func pushDeepLink(from response: UNNotificationResponse) -> DeepLink? {
        let userInfo = response.notification.request.content.userInfo

        guard let decryptedMessage = userInfo[DecryptedPushKeys.decryptedMessage] as? [String : Any],
              let spaceId = decryptedMessage[DecryptedPushKeys.spaceId] as? String,
              let chatId = decryptedMessage[DecryptedPushKeys.chatId] as? String else { return nil }

        let msgId = decryptedMessage[DecryptedPushKeys.msgId] as? String
        if let msgId, msgId.isNotEmpty {
            return .chatMessage(chatObjectId: chatId, spaceId: spaceId, messageId: msgId)
        } else {
            return .object(objectId: chatId, spaceId: spaceId)
        }
    }
    
    // MARK: - Termination
    
    func applicationWillTerminate(_ application: UIApplication) {
        middlewareShutdownService.shutdown()
        appSessionTracker.stopReportSession()
    }

}

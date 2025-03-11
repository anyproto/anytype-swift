import UserNotifications
import Services
import Factory

class NotificationService: UNNotificationServiceExtension {
    
    private let authMiddleService: any AuthMiddleServiceProtocol = Container.shared.authMiddleService()
    private let userInfoService: any UserInfoServiceProtocol = Container.shared.userInfoService()
    private let seedService: any SeedServiceProtocol = Container.shared.seedService()
    private let localRepoService: any LocalRepoServiceProtocol = Container.shared.localRepoService()
    private let serverConfigurationStorage: any ServerConfigurationStorageProtocol = Container.shared.serverConfigurationStorage()

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        Task {
            let content = UNMutableNotificationContent()
            if (try? await getAccountData()) != nil {
                content.title = "successful auth"
            } else {
                content.title = "failed auth"
            }
            contentHandler(content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler, let bestAttemptContent {
            bestAttemptContent.title = "time will expire"
            contentHandler(bestAttemptContent)
        }
    }
    
    private func getAccountData() async throws -> AccountData? {
        let userId = userInfoService.getUserId()
        guard !userId.isEmpty else {
            return nil
        }
        let rootPath = localRepoService.middlewareRepoPath
        let seed = try seedService.obtainSeed()
        try await authMiddleService.walletRecovery(rootPath: rootPath, mnemonic: seed)
        return try await authMiddleService.selectAccount(
            id: userId,
            rootPath: rootPath,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )
    }
}

import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore

final class AuthService: AuthServiceProtocol {
        
    private let rootPath: String
    private let loginStateService: LoginStateServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol
    private let serverConfigurationStorage: ServerConfigurationStorageProtocol
    private let authMiddleService: AuthMiddleServiceProtocol
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        loginStateService: LoginStateServiceProtocol,
        accountManager: AccountManagerProtocol,
        appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol,
        serverConfigurationStorage: ServerConfigurationStorageProtocol,
        authMiddleService: AuthMiddleServiceProtocol
    ) {
        self.rootPath = localRepoService.middlewareRepoPath
        self.loginStateService = loginStateService
        self.accountManager = accountManager
        self.appErrorLoggerConfiguration = appErrorLoggerConfiguration
        self.serverConfigurationStorage = serverConfigurationStorage
        self.authMiddleService = authMiddleService
    }

    func logout(removeData: Bool) async throws  {
        try await authMiddleService.logout(removeData: removeData)
        await loginStateService.cleanStateAfterLogout()
    }

    func createWallet() async throws -> String {
        try await authMiddleService.createWallet(rootPath: rootPath)
    }

    func createAccount(name: String, imagePath: String) async throws -> AccountData {
        let start = CFAbsoluteTimeGetCurrent()
        
        let account = try await authMiddleService.createAccount(
            name: name,
            imagePath: imagePath,
            gradient: GradientId.random,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )

        let middleTime = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
        
        let analyticsId = account.info.analyticsId
        AnytypeAnalytics.instance().setUserId(analyticsId)
        AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountCreate(analyticsId: analyticsId, middleTime: middleTime)
        AnytypeAnalytics.instance().logCreateSpace()
        appErrorLoggerConfiguration.setUserId(analyticsId)
        
        UserDefaultsConfig.usersId = account.id
        
        accountManager.account = account
        
        await loginStateService.setupStateAfterRegistration(account: account)
        return account
    }
    
    func walletRecovery(mnemonic: String) async throws {
        try await authMiddleService.walletRecovery(rootPath: rootPath, mnemonic: mnemonic)
    }

    func accountRecover() async throws {
        try await authMiddleService.accountRecover()
        loginStateService.setupStateAfterAuth()
    }
    
    func selectAccount(id: String) async throws -> AccountData {
        let account = try await authMiddleService.selectAccount(
            id: id,
            rootPath: rootPath,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )
        
        let analyticsId = account.info.analyticsId
        AnytypeAnalytics.instance().setUserId(analyticsId)
        AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountOpen(analyticsId: analyticsId)
        appErrorLoggerConfiguration.setUserId(analyticsId)
        
        switch account.status {
        case .active, .pendingDeletion:
            await setupAccountData(account)
        case .deleted:
            await loginStateService.cleanStateAfterLogout()
        }
        
        return account
    }
    
    private func setupAccountData(_ account: AccountData) async {
        UserDefaultsConfig.usersId = account.id
        accountManager.account = account
        await loginStateService.setupStateAfterLoginOrAuth(account: accountManager.account)
    }
    
    func deleteAccount() async throws -> AccountStatus {
        try await authMiddleService.deleteAccount()
    }
    
    func restoreAccount() async throws -> AccountStatus {
        try await authMiddleService.restoreAccount()
    }
    
    func mnemonicByEntropy(_ entropy: String) async throws -> String {
        try await authMiddleService.mnemonicByEntropy(entropy)
    }
}

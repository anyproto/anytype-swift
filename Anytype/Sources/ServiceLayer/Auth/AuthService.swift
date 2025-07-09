import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Services
import AnytypeCore

actor AuthService: AuthServiceProtocol, Sendable {
    
    private let localRepoService: any LocalRepoServiceProtocol = Container.shared.localRepoService()
    private let loginStateService: any LoginStateServiceProtocol = Container.shared.loginStateService()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()
    private let appErrorLoggerConfiguration: any AppErrorLoggerConfigurationProtocol = Container.shared.appErrorLoggerConfiguration()
    private let serverConfigurationStorage: any ServerConfigurationStorageProtocol = Container.shared.serverConfigurationStorage()
    private let authMiddleService: any AuthMiddleServiceProtocol = Container.shared.authMiddleService()
    private let basicUserInfoStorage: any BasicUserInfoStorageProtocol = Container.shared.basicUserInfoStorage()

    private let joinStreamUrl = FeatureFlags.joinStream ? Bundle.main.object(forInfoDictionaryKey: "JoinStreamURL") as? String ?? "" : ""
    
    private lazy var rootPath: String = {
        localRepoService.middlewareRepoPath
    }()
    
    func logout(removeData: Bool) async throws  {
        try await authMiddleService.logout(removeData: removeData)
        await loginStateService.cleanStateAfterLogout()
    }

    func createWallet() async throws -> String {
        try await authMiddleService.createWallet(rootPath: rootPath)
    }

    func createAccount(name: String, iconOption: Int, imagePath: String) async throws -> AccountData {
        let start = CFAbsoluteTimeGetCurrent()
        
        await loginStateService.setupStateBeforeLoginOrAuth()
        
        let account = try await authMiddleService.createAccount(
            name: name,
            imagePath: imagePath,
            iconOption: iconOption,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            joinStreamUrl: joinStreamUrl,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )

        let middleTime = Int(((CFAbsoluteTimeGetCurrent() - start) * 1_000)) // milliseconds
        
        let analyticsId = account.info.analyticsId
        AnytypeAnalytics.instance().setUserId(analyticsId)
        AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountCreate(analyticsId: analyticsId, middleTime: middleTime)
        AnytypeAnalytics.instance().logCreateSpace(spaceAccessType: .private, spaceUxType: .data, route: .navigation)
        await appErrorLoggerConfiguration.setUserId(analyticsId)
        
        basicUserInfoStorage.usersId = account.id
        basicUserInfoStorage.analyticsId = account.info.analyticsId
        
        accountManager.account = account
        
        await loginStateService.setupStateAfterRegistration(account: account)
        return account
    }
    
    func walletRecovery(mnemonic: String) async throws {
        try await authMiddleService.walletRecovery(rootPath: rootPath, mnemonic: mnemonic)
    }

    func accountRecover() async throws {
        try await authMiddleService.accountRecover()
        await loginStateService.setupStateAfterAuth()
    }
    
    func selectAccount(id: String) async throws -> AccountData {
        await loginStateService.setupStateBeforeLoginOrAuth()
        
        let account = try await authMiddleService.selectAccount(
            id: id,
            rootPath: rootPath,
            networkMode: serverConfigurationStorage.currentConfiguration().middlewareNetworkMode,
            joinStreamUrl: joinStreamUrl,
            useYamux: !FeatureFlags.quicLegacyTransport,
            configPath: serverConfigurationStorage.currentConfigurationPath()?.path ?? ""
        )
        
        let analyticsId = account.info.analyticsId
        AnytypeAnalytics.instance().setUserId(analyticsId)
        AnytypeAnalytics.instance().setNetworkId(account.info.networkId)
        AnytypeAnalytics.instance().logAccountOpen(analyticsId: analyticsId)
        await appErrorLoggerConfiguration.setUserId(analyticsId)
        
        switch account.status {
        case .active, .pendingDeletion:
            await setupAccountData(account)
        case .deleted:
            await loginStateService.cleanStateAfterLogout()
        }
        
        return account
    }
    
    private func setupAccountData(_ account: AccountData) async {
        basicUserInfoStorage.usersId = account.id
        basicUserInfoStorage.analyticsId = account.info.analyticsId
        
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

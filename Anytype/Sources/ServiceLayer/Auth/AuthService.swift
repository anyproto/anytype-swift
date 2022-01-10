import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Amplitude
import AnytypeCore
import BlocksModels

final class AuthService: AuthServiceProtocol {
    private let seedService: SeedServiceProtocol
    private let rootPath: String
    private let loginStateService: LoginStateService
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        seedService: SeedServiceProtocol,
        loginStateService: LoginStateService
    ) {
        self.seedService = seedService
        self.rootPath = localRepoService.middlewareRepoPath
        self.loginStateService = loginStateService
    }

    func logout() {
        Amplitude.instance().logEvent(AmplitudeEventsName.logout)
        
        _ = Anytype_Rpc.Account.Stop.Service.invoke(removeData: false)
        
        loginStateService.cleanStateAfterLogout()
    }

    func createWallet() -> Result<String, AuthServiceError> {
        let result = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: rootPath)
            .mapError { _ in AuthServiceError.createWalletError }
            .map { $0.mnemonic }
        
        if let mnemonic = result.getValue(domain: .authService) {
            AnytypeLogger.create("Services.AuthService").debugPrivate("seed:", arg: mnemonic)
            try? seedService.saveSeed(mnemonic)
        }
        
        return result
    }

    func createAccount(name: String, imagePath: String, alphaInviteCode: String) -> Result<Void, Error> {
        let result = Anytype_Rpc.Account.Create.Service
            .invoke(name: name, avatar: .avatarLocalPath(imagePath), alphaInviteCode: alphaInviteCode)
        
        if let response = result.getValue(domain: .authService) {
            AccountConfigurationProvider.shared.config = .init(config: response.config)
            
            let accountId = response.account.id
            Amplitude.instance().setUserId(accountId)
            Amplitude.instance().logAccountCreate(accountId)
            UserDefaultsConfig.usersId = accountId
        }
        
        return result.map { _ in }
    }

    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError> {
        try? seedService.saveSeed(mnemonic)
        
        let result = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: rootPath, mnemonic: mnemonic)
            .mapError { _ in AuthServiceError.recoverWalletError }
            .map { _ in Void() }

        return result
    }

    func accountRecover() -> AuthServiceError? {
        let result = Anytype_Rpc.Account.Recover.Service.invoke()
        switch result {
        case .success:
            return nil
        case .failure:
            return AuthServiceError.recoverAccountError
        }
    }

    func selectAccount(id: String) -> Bool {
        let result = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: rootPath)
                
        switch result {
        case .success(let response):
            AccountConfigurationProvider.shared.config = .init(config: response.config)
            
            let accountId = response.account.id
            Amplitude.instance().setUserId(accountId)
            Amplitude.instance().logAccountSelect(accountId)
            UserDefaultsConfig.usersId = accountId
            
            loginStateService.setupStateAfterLoginOrAuth()
            return true
        case .failure:
            return false
        }
    }
    
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error> {
        Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy)
            .map { $0.mnemonic }
            .mapError { _ in AuthServiceError.selectAccountError }
    }
}

import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import Amplitude
import AnytypeCore
import BlocksModels

private extension LoggerCategory {
    static let servicesAuthService: Self = "Services.AuthService"
}

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

    func logout(completion: @escaping () -> Void) {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.accountStop)
        
        _ = Anytype_Rpc.Account.Stop.Service.invoke(removeData: false)
        
        loginStateService.cleanStateAfterLogout()
        completion()
    }

    func createWallet() -> Result<String, AuthServiceError> {
        let result = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: rootPath)
            .mapError { _ in AuthServiceError.createWalletError }
            .map { $0.mnemonic }
        
        if let mnemonic = result.getValue() {
            Amplitude.instance().logEvent(AmplitudeEventsName.walletCreate)
            AnytypeLogger.create(.servicesAuthService).debugPrivate("seed:", arg: mnemonic)
            try? seedService.saveSeed(mnemonic)
        }
        
        return result
    }

    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String) -> Result<BlockId, AuthServiceError> {
        func transform(_ avatar: ProfileModel.Avatar) -> Anytype_Rpc.Account.Create.Request.OneOf_Avatar? {
            switch avatar {
            case let .imagePath(value): return .avatarLocalPath(value)
            }
        }
        
        let name = profile.name
        let avatar = transform(profile.avatar)

        let result = Anytype_Rpc.Account.Create.Service.invoke(name: name, avatar: avatar, alphaInviteCode: alphaInviteCode)
            .mapError { _ in AuthServiceError.createAccountError }
            .map { $0.account.id }
        
        if let accountId = result.getValue() {
            Amplitude.instance().setUserId(accountId)
            Amplitude.instance().logEvent(
                AmplitudeEventsName.accountCreate,
                withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
            )
            UserDefaultsConfig.usersIdKey = accountId
        }
        
        return result
    }

    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError> {
        try? seedService.saveSeed(mnemonic)
        
        let result = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: rootPath, mnemonic: mnemonic)
            .mapError { _ in AuthServiceError.recoverWalletError }
            .map { _ in Void() }

        Amplitude.instance().logEvent(AmplitudeEventsName.walletRecover)

        return result
    }

    func accountRecover() -> AuthServiceError? {
        let result = Anytype_Rpc.Account.Recover.Service.invoke()
        switch result {
        case .success:
            Amplitude.instance().logEvent(AmplitudeEventsName.accountRecover)
            return nil
        case .failure:
            return AuthServiceError.recoverAccountError
        }
    }

    func selectAccount(id: String) -> Result<BlockId, AuthServiceError> {
        let result = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: rootPath)
                
        switch result {
        case .success(let response):
            let accountId = response.account.id
            
            Amplitude.instance().setUserId(accountId)
            Amplitude.instance().logEvent(
                AmplitudeEventsName.accountSelect,
                withEventProperties: [AmplitudeEventsPropertiesKey.accountId : accountId]
            )

            UserDefaultsConfig.usersIdKey = accountId
            loginStateService.setupStateAfterLoginOrAuth()
            return .success(accountId)
        case .failure:
            return .failure(.selectAccountError)
        }
    }
    
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error> {
        Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy)
            .map { $0.mnemonic }
            .mapError { _ in AuthServiceError.selectAccountError }
    }
}

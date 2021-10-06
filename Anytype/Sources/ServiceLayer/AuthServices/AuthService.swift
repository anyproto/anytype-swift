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

    func createWallet(onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: rootPath).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createWalletError()))
            }
        }) { [weak self] (value) in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.walletCreate)
            AnytypeLogger.create(.servicesAuthService).debugPrivate("seed:", arg: value.mnemonic)

            try? self?.seedService.saveSeed(value.mnemonic)
        
            onCompletion(.success(()))
        }
    }

    func createAccount(profile: CreateAccountRequest, alphaInviteCode: String, onCompletion: @escaping OnCompletion) {
        func transform(_ avatar: ProfileModel.Avatar) -> Anytype_Rpc.Account.Create.Request.OneOf_Avatar? {
            switch avatar {
            case let .imagePath(value): return .avatarLocalPath(value)
            }
        }
        
        let name = profile.name
        let avatar = transform(profile.avatar)

        _ = Anytype_Rpc.Account.Create.Service.invoke(name: name, avatar: avatar, alphaInviteCode: alphaInviteCode).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createAccountError()))
            }
        }) { response in
            // Analytics
            Amplitude.instance().setUserId(response.account.id)
            Amplitude.instance().logEvent(AmplitudeEventsName.accountCreate,
                                          withEventProperties: [AmplitudeEventsPropertiesKey.accountId : response.account.id])

            UserDefaultsConfig.usersIdKey = response.account.id
            onCompletion(.success(response.account.id))
        }
    }

    func walletRecovery(mnemonic: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        try? seedService.saveSeed(mnemonic)
        _ = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: rootPath, mnemonic: mnemonic).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.recoverWalletError()))
            }
        }) { _ in
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.walletRecover)

            onCompletion(.success(()))
        }
    }

    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Account.Recover.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .receiveOnMain()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case let .failure(error): onCompletion(.failure(.recoverAccountError(message: error.localizedDescription)))
                }
            }) { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.accountRecover)
                
                onCompletion(.success(()))
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
            return .failure(.selectAccountError())
        }
    }
    
    func mnemonicByEntropy(_ entropy: String, completion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(_): completion(.failure(.selectAccountError()))
                }
            }) { response in
                completion(.success(response.mnemonic))
            }
    }
}

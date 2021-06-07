import Foundation
import Combine
import SwiftUI
import os
import ProtobufMessages

private extension LoggerCategory {
    static let servicesAuthService: Self = "Services.AuthService"
}

final class AuthService: AuthServiceProtocol {
    private let seedService: SeedServiceProtocol
    private let rootPath: String
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.seedService = seedService
        self.rootPath = localRepoService.middlewareRepoPath
    }

    func logout(completion: @escaping () -> Void) {
        _ = Anytype_Rpc.Account.Stop.Service.invoke(removeData: true)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receiveOnMain()
            .sinkWithDefaultCompletion("Logout") { [weak self] _ in
                try? self?.seedService.removeSeed()
                UserDefaultsConfig.usersIdKey = ""
                MiddlewareConfiguration.shared = nil
                
                completion()
        }
    }

    func createWallet(onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: rootPath).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createWalletError()))
            }
        }) { [weak self] (value) in
            Logger.create(.servicesAuthService).debug("seed: \(value.mnemonic, privacy: .private)")
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
            onCompletion(.success(()))
        }
    }

    func selectAccount(id: String, onCompletion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: rootPath)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished: break
                case .failure(_): onCompletion(.failure(.selectAccountError()))
                }
            }) { response in
                UserDefaultsConfig.usersIdKey = response.account.id
                onCompletion(.success(response.account.id))
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

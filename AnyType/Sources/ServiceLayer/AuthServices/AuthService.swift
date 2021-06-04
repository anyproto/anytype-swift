import Foundation
import Combine
import SwiftUI
import os
import ProtobufMessages

private extension LoggerCategory {
    static let servicesAuthService: Self = "Services.AuthService"
}

// rewrite it on top of Middleware services.
final class AuthService: NSObject, AuthServiceProtocol {
    private let localRepoService: LocalRepoServiceProtocol
    private let seedService: SeedServiceProtocol
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.localRepoService = localRepoService
        self.seedService = seedService
    }

    func logout(completion: @escaping () -> Void) {
        _ = Anytype_Rpc.Account.Stop.Service.invoke(removeData: true)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receiveOnMain()
            .sinkWithDefaultCompletion("Logout") { [weak self] _ in
                try? self?.seedService.removeSeed(for: UserDefaultsConfig.usersIdKey, keychainPassword: .userPresence)
                UserDefaultsConfig.usersIdKey = ""
                UserDefaultsConfig.userName = ""
                MiddlewareConfiguration.shared = nil
                
                completion()
        }
    }

    func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: path).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createWalletError()))
            }
        }) { [weak self] (value) in
            Logger.create(.servicesAuthService).debug("seed: \(value.mnemonic, privacy: .private)")
            try? self?.seedService.saveSeedForAccount(name: nil, seed: value.mnemonic, keychainPassword: .none)
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
        }) { [weak self] (value) in
            UserDefaultsConfig.usersIdKey = value.account.id
            UserDefaultsConfig.userName = value.account.name
            self?.replaceDefaultSeed(with: value.account.id, keychainPassword: .userPresence)
            onCompletion(.success(value.account.id))
        }
    }

    func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        try? seedService.saveSeedForAccount(name: nil, seed: mnemonic, keychainPassword: .none)
        _ = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: path, mnemonic: mnemonic).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.recoverWalletError()))
            }
        }) { (value) in
            onCompletion(.success(()))
        }
    }

    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Account.Recover.Service.invoke().subscribe(on: DispatchQueue.global()).receiveOnMain().sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case let .failure(error): onCompletion(.failure(.recoverAccountError(message: error.localizedDescription)))
            }
        }) { (value) in
            onCompletion(.success(()))
        }
    }

    func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: path).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): onCompletion(.failure(.selectAccountError()))
            }
        }) { [weak self] (value) in
            UserDefaultsConfig.usersIdKey = value.account.id
            UserDefaultsConfig.userName = value.account.name
            self?.replaceDefaultSeed(with: value.account.id, keychainPassword: .userPresence)
            onCompletion(.success(value.account.id))
        }
    }
    
    func mnemonicByEntropy(_ entropy: String, completion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy).sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case .failure(_): completion(.failure(.selectAccountError()))
            }
        }) { response in
            completion(.success(response.mnemonic))
        }
    }
}


// MARK: - Private methods

extension AuthService {
    private func replaceDefaultSeed(with name: String, keychainPassword: KeychainPasswordType) {
        if let seed = try? seedService.obtainSeed(for: nil, keychainPassword: .none) {
            try? seedService.saveSeedForAccount(name: name, seed: seed, keychainPassword: keychainPassword)
            try? seedService.removeSeed(for: nil, keychainPassword: .none)
        }
    }
}

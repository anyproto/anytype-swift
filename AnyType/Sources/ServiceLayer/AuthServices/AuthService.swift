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
    private let storeService: SecureStoreServiceProtocol
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        storeService: SecureStoreServiceProtocol
    ) {
        self.localRepoService = localRepoService
        self.storeService = storeService
    }

    func logout(completion: @escaping () -> Void) {
        _ = Anytype_Rpc.Account.Stop.Service.invoke(removeData: true)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .reciveOnMain()
            .sink(receiveCompletion: { result in
            }) { [weak self] _ in
                completion()
                try? FileManager.default.removeItem(atPath: self?.localRepoService.middlewareRepoPath ?? "")
                try? self?.storeService.removeSeed(for: UserDefaultsConfig.usersIdKey, keychainPassword: .userPresence)
                UserDefaultsConfig.usersIdKey = ""
                UserDefaultsConfig.userName = ""
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
            try? self?.storeService.saveSeedForAccount(name: nil, seed: value.mnemonic, keychainPassword: .none)
            onCompletion(.success(()))
        }
    }

    func createAccount(profile: AuthModels.CreateAccount.Request, alphaInviteCode: String, onCompletion: @escaping OnCompletion) {
        func transform(_ avatar: ProfileModel.Avatar) -> Anytype_Rpc.Account.Create.Request.OneOf_Avatar? {
            switch avatar {
            case let .color(value): return .avatarColor(value)
            case let .imagePath(value): return .avatarLocalPath(value)
                // possible @unknown default ???
            }
        }
        
        let name = profile.name
        let avatar = transform(profile.avatar)

        // TODO: Add screen to set AlphaInviteCode.

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
        try? self.storeService.saveSeedForAccount(name: nil, seed: mnemonic, keychainPassword: .none)
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
        _ = Anytype_Rpc.Account.Recover.Service.invoke().subscribe(on: DispatchQueue.global()).reciveOnMain().sink(receiveCompletion: { result in
            switch result {
            case .finished: break
            case let .failure(error): onCompletion(.failure(.recoverAccountError(message: error.localizedDescription)))
            }
        }) { (value) in
            onCompletion(.success(()))
        }
    }

    func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: path).reciveOnMain().sink(receiveCompletion: { result in
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
    
    func mnemonicByEntropy(entropy: String, completion: @escaping OnCompletion) {
        _ = Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy).reciveOnMain().sink(receiveCompletion: { result in
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
        if let seed = try? self.storeService.obtainSeed(for: nil, keychainPassword: .none) {
            try? self.storeService.saveSeedForAccount(name: name, seed: seed, keychainPassword: keychainPassword)
            try? self.storeService.removeSeed(for: nil, keychainPassword: .none)
        }
    }
}

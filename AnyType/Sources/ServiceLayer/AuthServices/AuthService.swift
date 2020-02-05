//
//  AuthService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import Lib
import SwiftUI

// rewrite it on top of Middleware services.
final class AuthService: NSObject, AuthServiceProtocol {
    @Environment(\.localRepoService) private var localRepoService
    private let storeService: SecureStoreServiceProtocol = KeychainStoreService()

    func login(recoveryPhrase: String, completion: @escaping (Error?) -> Void) {

    }

    func logout(completion: @escaping () -> Void) {
        completion()
        try? FileManager.default.removeItem(atPath: localRepoService.middlewareRepoPath)
        try? storeService.removeSeed(for: UserDefaultsConfig.usersIdKey, keyChainPassword: .userPresence)
        UserDefaultsConfig.usersIdKey = ""
        UserDefaultsConfig.userName = ""
    }

    func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Wallet.Create.Service.invoke(rootPath: path).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createWalletError()))
            }
        }) { (value) in
            try? self.storeService.saveSeedForAccount(name: nil, seed: value.mnemonic, keyChainPassword: .none)
            onCompletion(.success(()))
        }
    }

    func createAccount(profile: AuthModels.CreateAccount.Request, onCompletion: @escaping OnCompletion) {
        func transform(_ avatar: ProfileModel.Avatar) -> Anytype_Rpc.Account.Create.Request.OneOf_Avatar? {
            switch avatar {
            case let .color(value): return .avatarColor(value)
            case let .imagePath(value): return .avatarLocalPath(value)
                // possible @unknown default ???
            }
        }
        
        let name = profile.name
        let avatar = transform(profile.avatar)
        
        _ = Anytype_Rpc.Account.Create.Service.invoke(name: name, avatar: avatar).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case .failure(_): onCompletion(.failure(.createAccountError()))
            }
        }) { (value) in
            UserDefaultsConfig.usersIdKey = value.account.id
            UserDefaultsConfig.userName = value.account.name
            self.replaceDefaultSeed(with: value.account.id, keyChainPassword: .userPresence)
            onCompletion(.success(value.account.id))
        }
    }

    func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        try? self.storeService.saveSeedForAccount(name: nil, seed: mnemonic, keyChainPassword: .none)
        _ = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: path, mnemonic: mnemonic).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case .failure(_): onCompletion(.failure(.recoverWalletError()))
            }
        }) { (value) in
            onCompletion(.success(()))
        }
    }

    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {
        _ = Anytype_Rpc.Account.Recover.Service.invoke().sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case .failure(_): onCompletion(.failure(.recoverAccountError()))
            }
        }) { (value) in
            onCompletion(.success(()))
        }
    }

    func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {
        let theCompletion = { value in DispatchQueue.main.async { onCompletion(value) } }
        _ = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: path).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished: break
            case .failure(_): theCompletion(.failure(.selectAccountError()))
            }
        }) { (value) in
            UserDefaultsConfig.usersIdKey = value.account.id
            UserDefaultsConfig.userName = value.account.name
            self.replaceDefaultSeed(with: value.account.id, keyChainPassword: .userPresence)
            theCompletion(.success(value.account.id))
        }
    }
}


// MARK: - Private methods

extension AuthService {
    private func replaceDefaultSeed(with name: String, keyChainPassword: KeychainPasswordType) {
        if let seed = try? self.storeService.obtainSeed(for: nil, keyChainPassword: .none) {
            try? self.storeService.saveSeedForAccount(name: name, seed: seed, keyChainPassword: keyChainPassword)
            try? self.storeService.removeSeed(for: nil, keyChainPassword: .none)
        }
    }
}

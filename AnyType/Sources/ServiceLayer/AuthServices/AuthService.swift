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
    }
    
    func createWallet(in path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        var walletRequest = Anytype_Rpc.Wallet.Create.Request()
        walletRequest.rootPath = path
        
        let requestData = try? walletRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibWalletCreate(requestData),
                let response = try? Anytype_Rpc.Wallet.Create.Response(serializedData: data),
                response.error.code == .null
                else {
                    onCompletion(.failure(.createWalletError()))
                    return
            }
            try? self.storeService.saveSeedForAccount(name: nil, seed: response.mnemonic, keyChainPassword: .none)
            onCompletion(.success(()))
        }
    }
    
    func createAccount(profile: AuthModels.CreateAccount.Request, onCompletion: @escaping OnCompletion) {
        var createAccountRequest = Anytype_Rpc.Account.Create.Request()
        createAccountRequest.name = profile.name
        
        if case ProfileModel.Avatar.color(let color) = profile.avatar {
            createAccountRequest.avatarColor = color.description
        } else if case  ProfileModel.Avatar.imagePath(let path) = profile.avatar {
            createAccountRequest.avatarLocalPath = path
        }
        
        let requestData = try? createAccountRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibAccountCreate(requestData),
                let response = try? Anytype_Rpc.Account.Create.Response(serializedData: data),
                response.error.code == .null
                else {
                    onCompletion(.failure(.createAccountError()))
                    return
            }
            UserDefaultsConfig.usersIdKey = response.account.id
            self.replaceDefaultSeed(with: response.account.id, keyChainPassword: .userPresence)
            onCompletion(.success(response.account.id))
        }
    }
    
    func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        var walletRequest = Anytype_Rpc.Wallet.Recover.Request()
        walletRequest.rootPath = path
        walletRequest.mnemonic = mnemonic
        
        try? self.storeService.saveSeedForAccount(name: nil, seed: mnemonic, keyChainPassword: .none)
        
        let requestData = try? walletRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibWalletRecover(requestData),
                let response = try? Anytype_Rpc.Wallet.Recover.Response(serializedData: data),
                response.error.code == .null
                else {
                    onCompletion(.failure(.recoverWalletError()))
                    return
            }
            onCompletion(.success(()))
        }
    }
    
    func accountRecover(onCompletion: @escaping OnCompletionWithEmptyResult) {
        let accountRecoverRequest = Anytype_Rpc.Account.Recover.Request()
        
        let requestData = try? accountRecoverRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibAccountRecover(requestData),
                let response = try? Anytype_Rpc.Account.Select.Response(serializedData: data),
                response.error.code == .null
                else {
                    onCompletion(.failure(.recoverAccountError()))
                    return
            }
            onCompletion(.success(()))
        }
    }
    
    func selectAccount(id: String, path: String, onCompletion: @escaping OnCompletion) {
        var selectAccountRequest = Anytype_Rpc.Account.Select.Request()
        selectAccountRequest.id = id
        selectAccountRequest.rootPath = path
        
        let requestData = try? selectAccountRequest.serializedData()
        
        DispatchQueue.global().async {
            if let requestData = requestData {
                guard
                    let data = Lib.LibAccountSelect(requestData),
                    let response = try? Anytype_Rpc.Account.Select.Response(serializedData: data),
                    response.error.code == .null
                    else {
                        DispatchQueue.main.async {
                            onCompletion(.failure(.selectAccountError()))
                        }
                        return
                }
                UserDefaultsConfig.usersIdKey = response.account.id
                self.replaceDefaultSeed(with: response.account.id, keyChainPassword: .userPresence)
                
                DispatchQueue.main.async {
                    onCompletion(.success(response.account.id))
                }
            }
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

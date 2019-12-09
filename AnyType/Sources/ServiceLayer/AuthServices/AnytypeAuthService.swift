//
//  AnytypeAuthService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import Lib


final class AnytypeAuthService: NSObject, AuthServiceProtocol {
    
    func login(recoveryPhrase: String, completion: @escaping (Error?) -> Void) {
        
     }
     
     func logout(completion: @escaping () -> Void) {
         
     }
    
    func createWallet(in path: String, onCompletion: @escaping OnCompletion) {
//        getDocumentsDirectory().appendingPathComponent("textile-go").path
        
        var walletRequest = Anytype_Rpc.Wallet.Create.Request()
        walletRequest.rootPath = path
        
        let requestData = try? walletRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibWalletCreate(requestData),
                let response = try? Anytype_Rpc.Wallet.Create.Response(serializedData: data),
//                response.hasError == false
                response.error.code == .null
            else {
                onCompletion(.failure(.createWalletError()))
                return
            }
            onCompletion(.success(response.mnemonic))
        }
    }
    
    func createAccount(profile: AuthModels.CreateAccount.Request, onCompletion: @escaping OnCompletion) {
        var createAccountRequest = Anytype_Rpc.Account.Create.Request()
        createAccountRequest.name = profile.name
        
        if case ProfileModels.Avatar.color(let color) = profile.avatar {
            createAccountRequest.avatarColor = color.description
        } else if case  ProfileModels.Avatar.imagePath(let path) = profile.avatar {
            createAccountRequest.avatarLocalPath = path
        }
        
        let requestData = try? createAccountRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibAccountCreate(requestData),
                let response = try? Anytype_Rpc.Account.Create.Response(serializedData: data),
//                response.hasError == false
                response.error.code == .null
            else {
                onCompletion(.failure(.createAccountError()))
                return
            }
            onCompletion(.success(response.account.id))
        }
    }
    
    func walletRecovery(mnemonic: String, path: String, onCompletion: @escaping OnCompletionWithEmptyResult) {
        //        getDocumentsDirectory().appendingPathComponent("textile-go").path
        
        var walletRequest = Anytype_Rpc.Wallet.Recover.Request()
        walletRequest.rootPath = path
        
        let requestData = try? walletRequest.serializedData()
        
        if let requestData = requestData {
            guard
                let data = Lib.LibWalletRecover(requestData),
                let response = try? Anytype_Rpc.Wallet.Recover.Response(serializedData: data),
//                response.hasError == false
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
//                response.hasError == false
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
        
        if let requestData = requestData {
            guard
                let data = Lib.LibAccountSelect(requestData),
                let response = try? Anytype_Rpc.Account.Select.Response(serializedData: data),
//                response.hasError == false
                response.error.code == .null
            else {
                onCompletion(.failure(.selectAccountError()))
                return
            }
            onCompletion(.success(response.account.id))
        }
    }
}

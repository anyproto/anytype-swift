import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import AnytypeCore
import BlocksModels

final class AuthService: AuthServiceProtocol {
    private let seedService: SeedServiceProtocol
    private let rootPath: String
    private let loginStateService: LoginStateService
    
    private var subscriptions: [AnyCancellable] = []
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        seedService: SeedServiceProtocol,
        loginStateService: LoginStateService
    ) {
        self.seedService = seedService
        self.rootPath = localRepoService.middlewareRepoPath
        self.loginStateService = loginStateService
    }

    func logout(removeData: Bool, onCompletion: @escaping (Bool) -> ()) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.logout)
        
        Anytype_Rpc.Account.Stop.Service
            .invoke(removeData: removeData, queue: .global(qos: .userInitiated))
            .receiveOnMain()
            .sinkWithResult { [weak self] result in
                switch result {
                case .success:
                    self?.loginStateService.cleanStateAfterLogout()
                    onCompletion(true)
                case .failure(let error):
                    anytypeAssertionFailure(error.localizedDescription, domain: .authService)
                    onCompletion(false)
                }
            }
            .store(in: &subscriptions)
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

    func createAccount(name: String, imagePath: String, alphaInviteCode: String) -> Result<Void, CreateAccountServiceError> {
        let result = Anytype_Rpc.Account.Create.Service
            .invoke(name: name, avatar: .avatarLocalPath(imagePath), alphaInviteCode: alphaInviteCode)
        
        switch result {
        case .success(let response):
            return handleCreateAccount(response: response)
        case .failure(let error as NSError):
            guard
                let code = Anytype_Rpc.Account.Create.Response.Error.Code(rawValue: error.code),
                let serviceError = CreateAccountServiceError(code: code)
            else {
                return .failure(.unknownError)
            }
            
            return .failure(serviceError)
        }
    }
    
    private func handleCreateAccount(response: Anytype_Rpc.Account.Create.Response) -> Result<Void, CreateAccountServiceError> {
        if let error = CreateAccountServiceError(code: response.error.code) {
            return .failure(error)
        }

        let accountId = response.account.id
        AnytypeAnalytics.instance().setUserId(accountId)
        AnytypeAnalytics.instance().logAccountCreate(accountId)
        UserDefaultsConfig.usersId = accountId
        
        AccountManager.shared.account = response.account.asModel
        
        return .success(Void())
    }

    func walletRecovery(mnemonic: String) -> Result<Void, AuthServiceError> {
        try? seedService.saveSeed(mnemonic)
        
        let result = Anytype_Rpc.Wallet.Recover.Service.invoke(rootPath: rootPath, mnemonic: mnemonic)
            .mapError { _ in AuthServiceError.recoverWalletError }
            .map { _ in Void() }

        return result
    }

    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ()) {
        Anytype_Rpc.Account.Recover.Service.invoke(queue: .global(qos: .userInitiated))
            .receiveOnMain()
            .sinkWithResult { result in
                switch result {
                case .success(let data):
                    guard data.error.code == .null else {
                        return onCompletion(AuthServiceError.recoverAccountError(code: data.error.code))
                    }
                    return onCompletion(nil)
                case .failure(let error as NSError):
                    let code = RecoverAccountErrorCode(rawValue: error.code) ?? .null
                    return onCompletion(AuthServiceError.recoverAccountError(code: code))
                }
            }
            .store(in: &subscriptions)
    }

    func selectAccount(id: String) -> AccountStatus? {
        let result = Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: rootPath)
        return handleAccountSelect(result: result)
    }
    
    func selectAccount(id: String, onCompletion: @escaping (AccountStatus?) -> ()) {
        Anytype_Rpc.Account.Select.Service.invoke(id: id, rootPath: rootPath, queue: .global(qos: .userInitiated))
            .receiveOnMain()
            .sinkWithResult { [weak self] result in
                onCompletion(self?.handleAccountSelect(result: result))
            }
            .store(in: &subscriptions)
    }
    
    func deleteAccount() -> AccountStatus? {
        Anytype_Rpc.Account.Delete.Service.invoke(revert: false)
            .getValue(domain: .authService)
            .flatMap { $0.status.asModel }
    }
    
    func restoreAccount() -> AccountStatus? {
        Anytype_Rpc.Account.Delete.Service.invoke(revert: true)
            .getValue(domain: .authService)
            .flatMap { $0.status.asModel }
    }
    
    func mnemonicByEntropy(_ entropy: String) -> Result<String, Error> {
        Anytype_Rpc.Wallet.Convert.Service.invoke(mnemonic: "", entropy: entropy)
            .map { $0.mnemonic }
            .mapError { _ in AuthServiceError.selectAccountError }
    }
    
    // MARK: - Private
    private func handleAccountSelect(result: Result<Anytype_Rpc.Account.Select.Response, Error>) -> AccountStatus? {
        switch result {
        case .success(let response):
            AccountManager.shared.account = response.account.asModel
            
            let accountId = response.account.id
            AnytypeAnalytics.instance().setUserId(accountId)
            AnytypeAnalytics.instance().logAccountSelect(accountId)
            UserDefaultsConfig.usersId = accountId
            
            loginStateService.setupStateAfterLoginOrAuth()
            return response.account.status.asModel
        case .failure:
            return nil
        }
    }
    
}

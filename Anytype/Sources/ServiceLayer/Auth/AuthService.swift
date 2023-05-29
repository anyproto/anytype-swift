import Foundation
import Combine
import SwiftUI
import ProtobufMessages
import AnytypeCore
import BlocksModels

final class AuthService: AuthServiceProtocol {
    
    private enum AuthServiceParsingError: Error {
        case undefinedStatus(status: Anytype_Model_Account.Status)
    }
    
    private let rootPath: String
    private let loginStateService: LoginStateServiceProtocol
    private let accountManager: AccountManagerProtocol
    private let appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol
    
    private var subscriptions: [AnyCancellable] = []
    
    init(
        localRepoService: LocalRepoServiceProtocol,
        loginStateService: LoginStateServiceProtocol,
        accountManager: AccountManagerProtocol,
        appErrorLoggerConfiguration: AppErrorLoggerConfigurationProtocol
    ) {
        self.rootPath = localRepoService.middlewareRepoPath
        self.loginStateService = loginStateService
        self.accountManager = accountManager
        self.appErrorLoggerConfiguration = appErrorLoggerConfiguration
    }

    func logout(removeData: Bool, onCompletion: @escaping (Bool) -> ()) {
        Task { @MainActor [weak self] in
            do {
                try await ClientCommands.accountStop(.with {
                    $0.removeData = removeData
                }).invoke(errorDomain: .authService)
                self?.loginStateService.cleanStateAfterLogout()
                onCompletion(true)
            } catch {
                onCompletion(false)
            }
        }
        .cancellable()
        .store(in: &subscriptions)
    }

    func createWallet() throws -> String {
        do {
            let result = try ClientCommands.walletCreate(.with {
                $0.rootPath = rootPath
            }).invoke()
            return result.mnemonic
        } catch {
            throw AuthServiceError.createWalletError
        }
    }

    func createAccount(name: String, imagePath: String, alphaInviteCode: String) async throws {
        do {
            let response = try await ClientCommands.accountCreate(.with {
                $0.name = name
                $0.avatar = .avatarLocalPath(imagePath)
                $0.icon = Int64(GradientId.random.rawValue)
                $0.alphaInviteCode = alphaInviteCode
            }).invoke()
            
            let analyticsId = response.account.info.analyticsID
            AnytypeAnalytics.instance().setUserId(analyticsId)
            AnytypeAnalytics.instance().logAccountCreate(analyticsId: analyticsId)
            appErrorLoggerConfiguration.setUserId(analyticsId)
            
            UserDefaultsConfig.usersId = response.account.id
            
            accountManager.account = response.account.asModel
            
            await loginStateService.setupStateAfterRegistration(account: accountManager.account)
        } catch let responseError as Anytype_Rpc.Account.Create.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    func walletRecovery(mnemonic: String) throws {
        do {
            _ = try ClientCommands.walletRecover(.with {
                $0.rootPath = rootPath
                $0.mnemonic = mnemonic
            }).invoke()
        } catch {
            throw AuthServiceError.recoverWalletError
        }
    }
    
    func walletRecovery(mnemonic: String) async throws {
        try await ClientCommands.walletRecover(.with {
            $0.rootPath = rootPath
            $0.mnemonic = mnemonic
        }).invoke(errorDomain: .authService)
    }

    func accountRecover(onCompletion: @escaping (AuthServiceError?) -> ()) {
        Task { @MainActor [weak self] in
            do {
                _ = try ClientCommands.accountRecover().invoke()
                self?.loginStateService.setupStateAfterAuth()
                return onCompletion(nil)
            } catch {
                let code = (error as? Anytype_Rpc.Account.Recover.Response.Error)?.code ?? .null
                return onCompletion(AuthServiceError.recoverAccountError(code: code))
            }
        }
        .cancellable()
        .store(in: &subscriptions)
    }
    
    func selectAccount(id: String) async throws -> AccountStatus {
        do {
            let response = try await ClientCommands.accountSelect(.with {
                $0.id = id
                $0.rootPath = rootPath
            }).invoke()
            
            let analyticsId = response.account.info.analyticsID
            AnytypeAnalytics.instance().setUserId(analyticsId)
            AnytypeAnalytics.instance().logAccountSelect(analyticsId: analyticsId)
            appErrorLoggerConfiguration.setUserId(analyticsId)
            
            UserDefaultsConfig.usersId = response.account.id
            
            accountManager.account = response.account.asModel
            
            await loginStateService.setupStateAfterLoginOrAuth(account: accountManager.account)
            
            guard let status = response.account.status.asModel else {
                throw AuthServiceParsingError.undefinedStatus(status: response.account.status)
            }
            return status
        } catch let responseError as Anytype_Rpc.Account.Select.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    func deleteAccount() -> AccountStatus? {
        let result = try? ClientCommands.accountDelete(.with {
            $0.revert = false
        }).invoke(errorDomain: .authService)
        return result?.status.asModel
    }
    
    func restoreAccount() -> AccountStatus? {
        let result = try? ClientCommands.accountDelete(.with {
            $0.revert = true
        }).invoke(errorDomain: .authService)
        return result?.status.asModel
    }
    
    func mnemonicByEntropy(_ entropy: String) throws -> String {
        do {
            let result = try ClientCommands.walletConvert(.with {
                $0.entropy = entropy
            }).invoke()
            return result.mnemonic
        } catch {
            throw AuthServiceError.selectAccountError
        }
    }
}

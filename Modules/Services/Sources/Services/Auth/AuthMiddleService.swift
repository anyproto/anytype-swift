import Foundation
import ProtobufMessages
import AnytypeCore

public protocol AuthMiddleServiceProtocol: AnyObject {
    func logout(removeData: Bool)  async throws
    func createWallet(rootPath: String) async throws -> String
    func createAccount(
        name: String,
        imagePath: String,
        gradient: GradientId,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        configPath: String?
    ) async throws -> AccountData
    func walletRecovery(rootPath: String, mnemonic: String) async throws
    func accountRecover() async throws
    func selectAccount(
        id: String,
        rootPath: String,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        configPath: String?
    ) async throws -> AccountData
    func deleteAccount() async throws -> AccountStatus
    func restoreAccount() async throws -> AccountStatus
    func mnemonicByEntropy(_ entropy: String) async throws -> String
}

final class AuthMiddleService: AuthMiddleServiceProtocol {
    
    public func logout(removeData: Bool)  async throws {
        try await ClientCommands.accountStop(.with {
            $0.removeData = removeData
        }).invoke()
    }
    
    public func createWallet(rootPath: String) async throws -> String {
        let result = try await ClientCommands.walletCreate(.with {
            $0.rootPath = rootPath
        }).invoke()
        return result.mnemonic
    }
    
    public func createAccount(
        name: String,
        imagePath: String,
        gradient: GradientId,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        configPath: String?
    ) async throws -> AccountData {
        do {
            let response = try await ClientCommands.accountCreate(.with {
                $0.name = name
                $0.avatar = .avatarLocalPath(imagePath)
                $0.icon = Int64(gradient.rawValue)
                $0.disableLocalNetworkSync = true
                $0.networkMode = networkMode
                $0.networkCustomConfigFilePath = configPath ?? ""
            }).invoke()
    
            return try response.account.asModel()
        } catch let responseError as Anytype_Rpc.Account.Create.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    public func walletRecovery(rootPath: String, mnemonic: String) async throws {
        do {
            try await ClientCommands.walletRecover(.with {
                $0.rootPath = rootPath
                $0.mnemonic = mnemonic
            }).invoke(ignoreLogErrors: .badInput)
        } catch let responseError as Anytype_Rpc.Wallet.Recover.Response.Error {
            throw responseError.asError
        }
    }
    
    public func accountRecover() async throws {
        do {
            _ = try await ClientCommands.accountRecover().invoke()
        } catch {
            let code = (error as? Anytype_Rpc.Account.Recover.Response.Error)?.code ?? .null
            throw AuthServiceError.recoverAccountError(code: code)
        }
    }
    
    public func selectAccount(
        id: String,
        rootPath: String,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        configPath: String?
    ) async throws -> AccountData {
        do {
            let response = try await ClientCommands.accountSelect(.with {
                $0.id = id
                $0.rootPath = rootPath
                $0.disableLocalNetworkSync = false
                $0.networkMode = networkMode
                $0.networkCustomConfigFilePath = configPath ?? ""
            }).invoke()
            
            return try response.account.asModel()
        } catch let responseError as Anytype_Rpc.Account.Select.Response.Error {
            throw responseError.asError ?? responseError
        }
    }
    
    public func deleteAccount() async throws -> AccountStatus {
        do {
            let result = try await ClientCommands.accountDelete().invoke(ignoreLogErrors: .unableToConnect)
            return try result.status.asModel()
        } catch let error as Anytype_Rpc.Account.Delete.Response.Error {
            throw error.asError
        }
    }
    
    public func restoreAccount() async throws -> AccountStatus {
        let result = try await ClientCommands.accountRevertDeletion().invoke()
        return try result.status.asModel()
    }
    
    public func mnemonicByEntropy(_ entropy: String) async throws -> String {
        do {
            let result = try await ClientCommands.walletConvert(.with {
                $0.entropy = entropy
            }).invoke()
            return result.mnemonic
        } catch {
            throw AuthServiceError.selectAccountError
        }
    }
}

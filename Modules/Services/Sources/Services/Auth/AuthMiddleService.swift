import Foundation
import ProtobufMessages
import AnytypeCore

public protocol AuthMiddleServiceProtocol: AnyObject, Sendable {
    func logout(removeData: Bool)  async throws
    func createWallet(rootPath: String) async throws -> String
    func createAccount(
        name: String,
        imagePath: String,
        iconOption: Int,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        joinStreamUrl: String,
        configPath: String?
    ) async throws -> AccountData
    func walletRecovery(rootPath: String, mnemonic: String) async throws
    func accountRecover() async throws
    func selectAccount(
        id: String,
        rootPath: String,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        joinStreamUrl: String,
        useYamux: Bool,
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
        }).invoke(responseMask: { $0.mnemonic = "***" })
        return result.mnemonic
    }
    
    public func createAccount(
        name: String,
        imagePath: String,
        iconOption: Int,
        networkMode: Anytype_Rpc.Account.NetworkMode,
        joinStreamUrl: String,
        configPath: String?
    ) async throws -> AccountData {
        do {
            let response = try await ClientCommands.accountCreate(.with {
                $0.name = name
                $0.avatar = .avatarLocalPath(imagePath)
                $0.icon = Int64(iconOption)
                $0.disableLocalNetworkSync = true
                $0.networkMode = networkMode
                $0.joinStreamURL = joinStreamUrl
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
            }).invoke(requestMask: { $0.mnemonic = "***" }, ignoreLogErrors: .badInput)
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
        joinStreamUrl: String,
        useYamux: Bool,
        configPath: String?
    ) async throws -> AccountData {
        do {
            let response = try await ClientCommands.accountSelect(.with {
                $0.id = id
                $0.rootPath = rootPath
                $0.disableLocalNetworkSync = false
                $0.networkMode = networkMode
                $0.networkCustomConfigFilePath = configPath ?? ""
                $0.joinStreamURL = joinStreamUrl
                $0.preferYamuxTransport = useYamux
            }).invoke(ignoreLogErrors: .accountLoadIsCanceled, .accountStoreNotMigrated)
            
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
            }).invoke(responseMask: { $0.mnemonic = "***" })
            return result.mnemonic
        } catch {
            throw AuthServiceError.selectAccountError
        }
    }
}

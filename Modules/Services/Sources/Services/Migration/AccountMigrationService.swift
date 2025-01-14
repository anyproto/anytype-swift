import ProtobufMessages
import SwiftProtobuf
import AnytypeCore

public protocol AccountMigrationServiceProtocol: Sendable {
    func accountMigrate(id: String, rootPath: String) async throws
    func accountMigrateCancel(id: String) async throws
}

final class AccountMigrationService: AccountMigrationServiceProtocol {
    
    public func accountMigrate(id: String, rootPath: String) async throws {
        _ = try await ClientCommands.accountMigrate(.with {
            $0.id = id
            $0.rootPath = rootPath
        }).invoke()
    }

    public func accountMigrateCancel(id: String) async throws {
        _ = try await ClientCommands.accountMigrateCancel(.with {
            $0.id = id
        }).invoke()
    }
}

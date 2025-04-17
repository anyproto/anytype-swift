import Foundation
import ProtobufMessages

public enum AccountMigrationError: Error {
    case notEnoughFreeSpace(Int64)
}

extension Anytype_Rpc.Account.Migrate.Response.Error {
    var asError: AccountMigrationError? {
        switch code {
        case .notEnoughFreeSpace:
            return .notEnoughFreeSpace(requiredSpace)
        default:
            return nil
        }
    }
}

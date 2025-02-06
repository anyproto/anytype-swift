import Foundation
import ProtobufMessages

public enum AccountMigrationError: Error {
    case notEnoughFreeSpace
}

extension Anytype_Rpc.Account.Migrate.Response.Error {
    var asError: AccountMigrationError? {
        switch code {
        case .notEnoughFreeSpace:
            return .notEnoughFreeSpace
        default:
            return nil
        }
    }
}

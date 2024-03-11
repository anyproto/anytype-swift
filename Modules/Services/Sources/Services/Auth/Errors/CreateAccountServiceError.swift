import Foundation
import ProtobufMessages

public enum CreateAccountServiceError: Error {
    case unknownError
}

extension Anytype_Rpc.Account.Create.Response.Error {
    var asError: CreateAccountServiceError? {
        switch code {
        case .null: return nil
        case .unknownError, .badInput, .accountCreatedButFailedToStartNode, .accountCreatedButFailedToSetName, .failedToStopRunningNode, .failedToWriteConfig, .failedToCreateLocalRepo, .UNRECOGNIZED, .configFileNotFound, .configFileInvalid, .configFileNetworkIDMismatch:
            return .unknownError
        }
    }
}

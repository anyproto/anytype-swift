import Foundation
import ProtobufMessages

enum CreateAccountServiceError: Error {
    case unknownError
}

extension Anytype_Rpc.Account.Create.Response.Error {
    var asError: CreateAccountServiceError? {
        switch code {
        case .null: return nil
        case .unknownError, .badInput, .accountCreatedButFailedToStartNode, .accountCreatedButFailedToSetName, .failedToStopRunningNode, .failedToWriteConfig, .failedToCreateLocalRepo, .UNRECOGNIZED:
            return .unknownError
        }
    }
}

extension CreateAccountServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .unknownError: return Loc.unknownError
        }
    }
    
}

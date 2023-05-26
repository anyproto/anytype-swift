import Foundation
import ProtobufMessages

enum CreateAccountServiceError: Error {
    case unknownError
    
    case badInviteCode // = 900
    /// means general network error
    case networkError // = 901
    /// means we wasn't able to connect to the cafe server
    case networkConnectionRefused // = 902
    /// client can additionally support this error code to notify user that device is offline
    case networkOffline // = 903

}

extension Anytype_Rpc.Account.Create.Response.Error {
    var asError: CreateAccountServiceError? {
        switch code {
        case .null: return nil
        case .badInviteCode:
            return .badInviteCode
        case .netError:
            return .networkError
        case .netConnectionRefused:
            return .networkConnectionRefused
        case .netOffline:
            return .networkOffline
        case .unknownError, .badInput, .accountCreatedButFailedToStartNode , .accountCreatedButFailedToSetName,
                .accountCreatedButFailedToSetAvatar, .failedToStopRunningNode, .UNRECOGNIZED,
                .failedToWriteConfig, .failedToCreateLocalRepo:
            return .unknownError
        }
    }
}

extension CreateAccountServiceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .unknownError: return Loc.unknownError
        case .badInviteCode: return Loc.invalidInvitationCode
        case .networkError: return Loc.failedToCreateYourAccountDueToANetworkError
        case .networkConnectionRefused: return Loc.connectionRefused
        case .networkOffline: return Loc.yourDeviceSeemsToBeOffline
        }
    }
    
}

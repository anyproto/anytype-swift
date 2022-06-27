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

extension CreateAccountServiceError {
    
    init?(code: Anytype_Rpc.Account.Create.Response.Error.Code) {
        switch code {
        case .null: return nil
        case .badInviteCode:
            self = .badInviteCode
        case .netError:
            self = .networkError
        case .netConnectionRefused:
            self = .networkConnectionRefused
        case .netOffline:
            self = .networkOffline
            
        case .unknownError, .badInput, .accountCreatedButFailedToStartNode , .accountCreatedButFailedToSetName, .accountCreatedButFailedToSetAvatar, .failedToStopRunningNode, .UNRECOGNIZED:
            self = .unknownError
        }
    }
    
}

extension CreateAccountServiceError {
    
    var localizedDescription: String {
        switch self {
        case .unknownError: return Loc.unknownError
        case .badInviteCode: return Loc.invalidInvitationCode
        case .networkError: return Loc.failedToCreateYourAccountDueToANetworkError
        case .networkConnectionRefused: return Loc.ConnectionRefused.pleaseTryAgain
        case .networkOffline: return Loc.YourDeviceSeemsToBeOffline.pleaseCheckYourConnectionAndTryAgain
        }
    }
    
}

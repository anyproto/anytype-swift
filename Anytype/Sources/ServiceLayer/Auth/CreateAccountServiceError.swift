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
        case .unknownError: return "Unknown error".localized
        case .badInviteCode: return "Invalid invitation code".localized
        case .networkError: return "Failed to create your account due to a network error".localized
        case .networkConnectionRefused: return "Connection refused. Please, try again".localized
        case .networkOffline: return "Your device seems to be offline. Please, check your connection and try again".localized
        }
    }
    
}

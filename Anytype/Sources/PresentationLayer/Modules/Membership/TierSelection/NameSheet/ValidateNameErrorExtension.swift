import Services
import ProtobufMessages
import Foundation


extension MembershipServiceProtocol.ValidateNameError {
    public var validateNameSheetError: String {
        switch code {
        case .tooShort:
            Loc.Membership.NameForm.Error.tooShort
        case .tooLong:
            Loc.Membership.NameForm.Error.tooLong
        case .hasInvalidChars:
            Loc.Membership.NameForm.Error.hasInvalidChars
        case .canNotConnect:
            Loc.Error.unableToConnect
        case .canNotReserve:
            Loc.Membership.NameForm.Error.canNotReserve
        case .tierFeaturesNoName, .notLoggedIn, .paymentNodeError, .cacheError, .tierNotFound:
            Loc.ErrorOccurred.pleaseTryAgain
        case .UNRECOGNIZED, .unknownError, .null, .badInput: // System errors
            Loc.ErrorOccurred.pleaseTryAgain
        }
    }
}

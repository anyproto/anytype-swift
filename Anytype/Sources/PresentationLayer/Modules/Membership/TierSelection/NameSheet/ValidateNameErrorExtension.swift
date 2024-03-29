import Services
import ProtobufMessages
import Foundation


extension MembershipServiceProtocol.ValidateNameError: LocalizedError {
    public var validateNameSheetError: String {
        switch code {
        case .tooShort:
            Loc.Membership.NameForm.Error.tooShort
        case .tooLong:
            Loc.Membership.NameForm.Error.tooLong
        case .hasInvalidChars:
            Loc.Membership.NameForm.Error.hasInvalidChars
        case .UNRECOGNIZED, .unknownError, .null, .badInput, .tierFeaturesNoName:
            Loc.ErrorOccurred.pleaseTryAgain
        }
    }
}

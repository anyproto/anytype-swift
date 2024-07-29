import Services
import Foundation


extension MembershipServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .tierNotFound:
            Loc.MembershipServiceError.tierNotFound
        case .invalidBillingIdFormat:
            Loc.MembershipServiceError.invalidBillingIdFormat
        }
    }
}


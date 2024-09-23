import Foundation
import Services

extension CreateAccountServiceError: @retroactive LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unknownError: return Loc.unknownError
        }
    }
    
}

import Foundation
import Services

extension AccountDeleteError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unableToConnect: return Loc.Error.unableToConnect
        case .unknownError: return Loc.unknownError
        }
    }
}

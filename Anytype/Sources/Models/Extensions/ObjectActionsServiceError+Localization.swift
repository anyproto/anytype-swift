import Foundation
import Services

extension ObjectActionsServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nothingToUndo:
            return Loc.nothingToUndo
        case .nothingToRedo:
            return Loc.nothingToRedo
        }
    }
}

import Foundation
import Services

extension ObjectActionsServiceError {
    var message: String {
        switch self {
        case .nothingToUndo:
            return Loc.nothingToUndo
        case .nothingToRedo:
            return Loc.nothingToRedo
        }
    }
}

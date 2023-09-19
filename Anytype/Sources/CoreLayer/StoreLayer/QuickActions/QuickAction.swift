import UIKit

enum QuickAction: String, CaseIterable {
    case newObject
}

extension QuickAction {
    func toAppAction() -> AppAction {
        switch self {
        case .newObject:
            return .createObject
        }
    }
}

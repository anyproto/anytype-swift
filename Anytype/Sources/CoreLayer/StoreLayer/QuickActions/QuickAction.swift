import UIKit

enum QuickAction {
    case newObject(typeId: String)
}

extension QuickAction {
    func toAppAction() -> AppAction {
        switch self {
        case .newObject(let typeId):
            return .createObjectFromQuickAction(typeId: typeId)
        }
    }
}

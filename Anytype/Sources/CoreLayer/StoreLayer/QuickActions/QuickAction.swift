import UIKit

enum QuickAction {
    case newObject(typeId: String)
}

extension QuickAction {
    func toAppAction() -> AppAction {
        switch self {
        case .newObject(let typeId):
            return .createObject(typeId: typeId)
        }
    }
}

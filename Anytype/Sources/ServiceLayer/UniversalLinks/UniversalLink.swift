import Foundation
import DeepLinks

enum UniversalLink: Equatable {
    case invite(cid: String, key: String)
}

extension UniversalLink {
    func toDeepLink() -> DeepLink {
        switch self {
        case .invite(let cid, let key):
            return .invite(cid: cid, key: key)
        }
    }
}

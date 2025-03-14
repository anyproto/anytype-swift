import Foundation
import DeepLinks

enum UniversalLink: Equatable {
    case invite(cid: String, key: String)
    case object(objectId: String, spaceId: String, cid: String? = nil, key: String? = nil)
}

extension UniversalLink {
    func toDeepLink() -> DeepLink {
        switch self {
        case .invite(let cid, let key):
            return .invite(cid: cid, key: key)
        case .object(let objectId, let spaceId, let cid, let key):
            return .object(objectId: objectId, spaceId: spaceId, cid: cid, key: key)
        }
    }
}

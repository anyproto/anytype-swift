//import Services
//
//extension BlockLinkState {
//
//    enum Style: Hashable, Equatable {
//        case noContent
//        case icon(ObjectIcon)
//        case checkmark(Bool)
//
//        var isCheckmark: Bool {
//            if case .checkmark = self {
//                return true
//            }
//            return false
//        }
//    }
//}
//
//extension BlockLinkState.Style {
//
//    init(details: ObjectDetails) {
//        if let objectIcon = details.icon {
//            self = .icon(objectIcon)
//            return
//        }
//
//        guard case .todo = details.layoutValue else {
//            self = .noContent
//            return
//        }
//
//        self = .checkmark(details.isDone)
//    }
//
//}

import ProtobufMessages
import CoreGraphics

enum AccountStatus: Equatable {
    case active
    case pendingDeletion(deadline: Date)
    case deleted
}

extension Anytype_Model_Account.Status {
    var asModel: AccountStatus? {
        switch self.statusType {
        case .startedDeletion, .deleted:
            return .deleted
        case .active:
            return .active
        case .pendingDeletion:
            return .pendingDeletion(
                deadline: Date(timeIntervalSince1970: TimeInterval(deletionDate))
            )
        case .UNRECOGNIZED:
            return nil
        }
    }
}

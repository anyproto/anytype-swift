import ProtobufMessages
import CoreGraphics

enum AccountStatus: Equatable {
    case active
    case pendingDeletion(progress: DeletionProgress)
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
            let progress = DeletionProgress(
                deadline: Date(timeIntervalSince1970: TimeInterval(deletionDate))
            )
            progress.daysToDeletion
            
            
            return .pendingDeletion(progress: progress)
        case .UNRECOGNIZED:
            return nil
        }
    }
}

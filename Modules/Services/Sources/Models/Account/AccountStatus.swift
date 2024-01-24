import ProtobufMessages
import CoreGraphics
import Foundation

public enum AccountStatus: Equatable {
    case active
    case pendingDeletion(deadline: Date)
    case deleted
}

public extension Anytype_Model_Account.Status {
    
    func asModel() throws -> AccountStatus {
        switch self.statusType {
        case .startedDeletion, .deleted:
            return .deleted
        case .active:
            return .active
        case .pendingDeletion:
            let deadline = Date(timeIntervalSince1970: TimeInterval(deletionDate))
            let deadlineTimeIntervalSince1970 = deadline.timeIntervalSince1970
            let nowTimeIntervalSince1970 = Date().timeIntervalSince1970
            let remainingTimeInterval = deadlineTimeIntervalSince1970 - nowTimeIntervalSince1970
            
            guard remainingTimeInterval > 0 else {
                return .deleted
            }
            
            return .pendingDeletion(deadline: deadline)
        case .UNRECOGNIZED:
            throw CommonConvertError.commonError
        }
    }
}

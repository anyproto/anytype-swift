import Foundation
import ProtobufMessages

public typealias SpaceAccessType = Anytype_Model_SpaceAccessType

public extension SpaceAccessType {
    var isSharable: Bool {
        switch self {
        case .private, .shared:
            true
        case .personal, .UNRECOGNIZED:
            false
        }
    }
    
    var isShared: Bool {
        switch self {
        case .shared:
            true
        case .private, .personal, .UNRECOGNIZED:
            false
        }
    }
    
    var isDeletable: Bool {
        switch self {
        case .private, .personal, .shared:
            true
        case .UNRECOGNIZED:
            false
        }
    }
}

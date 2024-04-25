import Foundation
import Services

extension SpaceAccessType {
    var analyticsType: SpaceAccessAnalyticsType {
        switch self {
        case .shared:
            return .shared
        case .private:
            return .private
        case .personal:
            return .personal
        case .UNRECOGNIZED:
            return .unrecognized
        }
    }
}

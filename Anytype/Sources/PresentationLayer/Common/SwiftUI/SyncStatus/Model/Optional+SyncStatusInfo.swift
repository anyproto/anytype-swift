import Services
import SwiftUI

extension Optional where Wrapped == SyncStatusInfo {
    var networkTitle: String {
        switch self {
        case .none:
            SyncStatusInfo.defaultNetworkTitle
        case .some(let wrapped):
            wrapped.networkTitle
        }
    }
    
    var networkSubtitle: String {
        switch self {
        case .none:
            SyncStatusInfo.defaultNetworkSubtitle
        case .some(let wrapped):
            wrapped.networkSubtitle
        }
    }
    
    var networkIcon: ImageAsset {
        switch self {
        case .none:
            SyncStatusInfo.defaultnetworkIcon
        case .some(let wrapped):
            wrapped.networkIcon
        }
    }
    
    var networkIconColor: Color {
        switch self {
        case .none:
            SyncStatusInfo.defaultNetworkIconColor
        case .some(let wrapped):
            wrapped.networkIconColor
        }
    }
}

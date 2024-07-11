import Services
import SwiftUI


extension SyncStatusInfo {
    var networkTitle: String {
        return "Anytype Network" // TBD
    }
    
    var networkSubtitle: String {
        return "End-to-end encrypted" // TBD
    }
    
    var networkIcon: ImageAsset {
        switch network {
        case .anytype:
            anytypeNetworkIcon
        case .selfHost:
            selfHostIcon
        case .localOnly:
            anytypeNetworkIcon
        case .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncOffline
        }
    }
    
    var networkIconColor: Color {
        switch status {
        case .synced, .syncing:
            .Light.green
        case .error:
            .Light.red
        case .offline, .UNRECOGNIZED:
            .Shape.tertiary
        }
    }
    
    // MARK: - Private
    private var anytypeNetworkIcon: ImageAsset {
        switch status {
        case .synced, .syncing:
            ImageAsset.SyncStatus.syncAnytypenetworkConnected
        case .error:
            ImageAsset.SyncStatus.syncAnytypenetworkError
        case .offline, .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncOffline
        }
    }
    
    private var selfHostIcon: ImageAsset {
        switch self.status {
        case .synced, .syncing:
            ImageAsset.SyncStatus.syncSelfhostConnected
        case .error:
            ImageAsset.SyncStatus.syncSelfhostError
        case .offline, .UNRECOGNIZED:
            ImageAsset.SyncStatus.syncSelfhostDefault
        }
    }
    
    private var localOnlyIcon: ImageAsset {
        ImageAsset.SyncStatus.syncLocalonlyDefault
    }
}

extension Optional where Wrapped == SyncStatusInfo {
    var networkTitle: String {
        switch self {
        case .none:
            "Connecting..."
        case .some(let wrapped):
            wrapped.networkTitle
        }
    }
    
    var networkSubtitle: String {
        switch self {
        case .none:
            ""
        case .some(let wrapped):
            wrapped.networkSubtitle
        }
    }
    
    var networkIcon: ImageAsset {
        switch self {
        case .none:
            ImageAsset.SyncStatus.syncOffline
        case .some(let wrapped):
            wrapped.networkIcon
        }
    }
    
    var networkIconColor: Color {
        switch self {
        case .none:
            .Shape.tertiary
        case .some(let wrapped):
            wrapped.networkIconColor
        }
    }
}

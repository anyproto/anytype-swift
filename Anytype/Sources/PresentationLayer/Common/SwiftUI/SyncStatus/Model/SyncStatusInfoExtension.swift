import Services
import SwiftUI


extension SyncStatusInfo {
    static func `default`(spaceId: String) -> SyncStatusInfo {
        var info = SyncStatusInfo()
        info.network = .UNRECOGNIZED(1337)
        info.id = spaceId
        return info
    }
}

// Texts
extension SyncStatusInfo {
    var networkTitle: String {
        switch network {
        case .anytype:
            Loc.anytypeNetwork
        case .selfHost:
            Loc.selfHost
        case .localOnly:
            Loc.localOnly
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
    
    var networkSubtitle: String {
        switch network {
        case .anytype:
            anytypeNetworkSubtitle
        case .selfHost:
            anytypeSelfhostSubtitle
        case .localOnly:
            Loc.SyncStatus.Info.localOnly
        case .UNRECOGNIZED:
            ""
        }
    }
    
    private var anytypeNetworkSubtitle: String {
        switch self.status {
        case .synced:
            Loc.SyncStatus.Info.anytypeNetwork
        case .syncing:
            Loc.itemsSyncing(Int(syncingObjectsCounter))
        case .error:
            error.localizedDescription
        case .offline:
            Loc.noConnection
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
    
    private var anytypeSelfhostSubtitle: String {
        switch self.status {
        case .synced:
            Loc.synced
        case .syncing:
            Loc.itemsSyncing(Int(syncingObjectsCounter))
        case .error:
            error.localizedDescription
        case .offline:
            Loc.noConnection
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
}

// MARK: - NetworkIconProvider
extension SyncStatusInfo: NetworkIconProvider {
    var iconData: NetworkIconData {
        switch network {
        case .anytype:
            anytypeNetworkIcon
        case .selfHost:
            selfHostIcon
        case .localOnly:
            localOnlyIcon
        case .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncOffline,
                color: .Button.active
            )
        }
    }
    
    var background: NetworkIconBackground {
        switch self.network {
        case .anytype, .selfHost:
            networkIconColorBasedOnStatus
        case .localOnly, .UNRECOGNIZED:
            .static(.Shape.secondary)
        }
    }
    
    private var networkIconColorBasedOnStatus: NetworkIconBackground {
        switch status {
        case .synced:
            .static(.Light.green)
        case .syncing:
            .animation(start: .Light.green, end: .Light.green.opacity(0.5))
        case .error:
            .static(.Light.red)
        case .offline, .UNRECOGNIZED:
            .static(.Shape.secondary)
        }
    }
    
    private var anytypeNetworkIcon: NetworkIconData {
        switch status {
        case .synced, .syncing:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncAnytypenetworkConnected,
                color: .Dark.green
            )
        case .error:
            NetworkIconData(
                icon:ImageAsset.SyncStatus.syncAnytypenetworkError,
                color: .System.red
            )
        case .offline, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncOffline,
                color: .Button.active
            )
        }
    }
    
    private var selfHostIcon: NetworkIconData {
        switch self.status {
        case .synced, .syncing:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncSelfhost,
                color: .Dark.green
            )
        case .error:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncSelfhost,
                color: .System.red
            )
        case .offline, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncSelfhost,
                color: .Button.active
            )
        }
    }
    
    private var localOnlyIcon: NetworkIconData {
        NetworkIconData(
            icon: ImageAsset.SyncStatus.syncLocalonlyDefault,
            color: .Button.active
        )
    }
}

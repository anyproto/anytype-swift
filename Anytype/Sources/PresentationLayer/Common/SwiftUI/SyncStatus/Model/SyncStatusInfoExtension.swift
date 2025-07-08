import Services
import SwiftUI


extension SpaceSyncStatusInfo {
    static func `default`(spaceId: String) -> SpaceSyncStatusInfo {
        var info = SpaceSyncStatusInfo()
        info.network = .UNRECOGNIZED(1337)
        info.id = spaceId
        return info
    }
}

// Texts
extension SpaceSyncStatusInfo {
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
        case .networkNeedsUpdate:
            Loc.SyncStatus.Info.networkNeedsUpdate
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
        case .networkNeedsUpdate:
            Loc.SyncStatus.Info.networkNeedsUpdate
        case .UNRECOGNIZED:
            Loc.connecting
        }
    }
}

// MARK: - NetworkIconProvider
extension SpaceSyncStatusInfo: NetworkIconProvider {
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
                color: .Control.active
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
    
    var haveTapIndicatior: Bool {
        switch status {
        case .networkNeedsUpdate:
            true
        case .synced, .syncing, .error, .offline, .UNRECOGNIZED:
            false
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
        case .networkNeedsUpdate:
            .static(.Light.yellow)
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
                color: .Pure.red
            )
        case .networkNeedsUpdate:
            NetworkIconData(
                icon:ImageAsset.SyncStatus.syncOffline,
                color: .Dark.yellow
            )
        case .offline, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncOffline,
                color: .Control.active
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
                color: .Pure.red
            )
        case .networkNeedsUpdate:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncSelfhost,
                color: .Dark.yellow
            )
        case .offline, .UNRECOGNIZED:
            NetworkIconData(
                icon: ImageAsset.SyncStatus.syncSelfhost,
                color: .Control.active
            )
        }
    }
    
    private var localOnlyIcon: NetworkIconData {
        NetworkIconData(
            icon: ImageAsset.SyncStatus.syncLocalonlyDefault,
            color: .Control.active
        )
    }
}

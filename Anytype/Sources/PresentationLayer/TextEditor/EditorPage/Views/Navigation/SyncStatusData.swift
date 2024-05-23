import Services
import UIKit

struct SyncStatusData {
    let status: SyncStatus
    let networkId: String
    let isHidden: Bool
    
    var title: String {
        guard networkId.isNotEmpty else { return Loc.SyncStatus.LocalOnly.title }
        switch status {
        case .unknown:
            return Loc.preparing
        case .offline:
            return Loc.noConnection
        case .syncing:
            return Loc.syncing
        case .synced:
            return Loc.synced
        case .failed, .incompatibleVersion:
            return Loc.notSyncing
        }
    }
    
    var description: String {
        guard networkId.isNotEmpty else { return Loc.SyncStatus.LocalOnly.description }
        switch status {
        case .unknown:
            return Loc.initializingSync
        case .offline:
            return Loc.nodeIsNotConnected
        case .syncing:
            return Loc.downloadingOrUploadingDataToSomeNode
        case .synced:
            return syncedDescription
        case .failed:
            return Loc.failedToSyncTryingAgain
        case .incompatibleVersion:
            return Loc.Sync.Status.Version.Outdated.description
        }
    }
    
    var image: UIImage? {
        guard let color else { return nil }
        return ImageBuilder(
            ImageGuideline(
                size: CGSize(width: 10, height: 10),
                radius: .point(5)
            )
        )
        .setImageColor(color).build()
    }
    
    private var color: UIColor? {
        guard networkId.isNotEmpty else { return nil }
        switch status {
        case .failed, .incompatibleVersion:
            return UIColor.System.red
        case .syncing:
            return UIColor.System.amber100
        case .synced:
            return UIColor.System.green
        case .unknown, .offline:
            return nil
        }
    }
    
    private var syncedDescription: String {
        if networkId == NetworkIds.anytype {
            return Loc.SyncStatus.Synced.Anytype.description
        } else if networkId == NetworkIds.anytypeStaging {
            return Loc.SyncStatus.Synced.AnytypeStaging.description
        } else {
            return Loc.SyncStatus.Synced.SelfHosted.description
        }
    }
}


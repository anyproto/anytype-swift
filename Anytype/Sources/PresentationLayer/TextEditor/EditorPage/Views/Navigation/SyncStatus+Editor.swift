import Services
import UIKit
import Kingfisher

extension SyncStatus {
    var title: String {
        switch self {
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
        switch self {
        case .unknown:
            return Loc.initializingSync
        case .offline:
            return Loc.anytypeNodeIsNotConnected
        case .syncing:
            return Loc.downloadingOrUploadingDataToSomeNode
        case .synced:
            return Loc.backedUpOnOneNodeAtLeast
        case .failed:
            return Loc.failedToSyncTryingAgain
        case .incompatibleVersion:
            return Loc.Sync.Status.Version.Outdated.description
        }
    }
    
    var image: UIImage? {
        guard shouldShowImage else { return nil }
        return ImageBuilder(
            ImageGuideline(
                size: CGSize(width: 10, height: 10),
                radius: .point(5)
            )
        )
            .setImageColor(color).build()
    }
    
    private var shouldShowImage: Bool {
        switch self {
        case .failed, .incompatibleVersion, .syncing, .synced:
            return true
        case .unknown, .offline:
            return false
        }
    }
    
    private var color: UIColor {
        switch self {
        case .offline, .failed, .incompatibleVersion:
            return UIColor.System.red
        case .syncing, .unknown:
            return UIColor.System.amber100
        case .synced:
            return UIColor.System.green
        }
    }
    
}

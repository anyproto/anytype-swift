import BlocksModels
import UIKit
import Kingfisher

extension SyncStatus {
    var title: String {
        switch self {
        case .unknown:
            return "Preparing...".localized
        case .offline:
            return "No connection".localized
        case .syncing:
            return "Syncing...".localized
        case .synced:
            return "Synced".localized
        case .failed:
            return "Not syncing".localized
        }
    }
    
    var description: String {
        switch self {
        case .unknown:
            return "Initializing sync".localized
        case .offline:
            return "Anytype node is not connected".localized
        case .syncing:
            return "Downloading or uploading data to some node".localized
        case .synced:
            return "Backed up on one node at least".localized
        case .failed:
            return "Failed to sync, trying again...".localized
        }
    }
    
    var image: UIImage {
        ImageBuilder(
            ImageGuideline(
                size: CGSize(width: 10, height: 10),
                cornersGuideline: .init(radius: 5, borderColor: nil)
            )
        )
            .setImageColor(color).build()
    }
    
    private var color: UIColor {
        switch self {
        case .offline, .failed:
            return UIColor.System.red
        case .syncing, .unknown:
            return UIColor.System.amber
        case .synced:
            return UIColor.System.green
        }
    }
    
}

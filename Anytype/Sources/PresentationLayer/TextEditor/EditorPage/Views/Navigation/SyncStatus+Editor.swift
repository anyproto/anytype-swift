import BlocksModels
import UIKit
import Kingfisher

extension SyncStatus {
    var color: UIColor {
        switch self {
        case .unknown, .offline, .failed:
            return .pureRed
        case .syncing:
            return .pureAmber
        case .synced:
            return .pureGreen
        }
    }
    
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
}

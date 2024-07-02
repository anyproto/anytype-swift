import Services
import UIKit

struct SyncStatusData {
    let status: SyncStatus
    let networkId: String
    let isHidden: Bool
    
    var isLocalOnly: Bool { networkId.isEmpty }
    var isNotLocalOnly: Bool { !isLocalOnly }
    
    
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
        guard isNotLocalOnly else {
            return UIColor.Button.active
        }
        switch status {
        case .failed, .incompatibleVersion:
            return UIColor.System.red
        case .syncing:
            return UIColor.System.green // TODO: Add animation
        case .synced:
            return UIColor.System.green
        case .offline:
            return UIColor.Button.active
        case .unknown, .UNRECOGNIZED:
            return UIColor.Button.active // TODO: Add animation
        }
    }
}


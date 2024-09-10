import Services
import UIKit

enum SyncStatusIconType {
    case image(UIImage)
    case animation(UIImage, UIImage)
}

struct SyncStatusData {
    let status: SyncStatus
    let networkId: String
    let isHidden: Bool
    
    var isLocalOnly: Bool { networkId.isEmpty }
    var isNotLocalOnly: Bool { !isLocalOnly }
    
    var icon: SyncStatusIconType {
        guard isNotLocalOnly else {
            return .image(makeIcon(color: .Button.active))
        }
        
        switch status {
        case .error:
            return .image(makeIcon(color: .System.red))
        case .networkNeedsUpdate:
            return .image(makeIcon(color: .Light.yellow))
        case .syncing:
            return .animation(
                makeIcon(color: .System.green, diameter: 8),
                UIImage(asset: ImageAsset.SyncStatus.syncInProgress) ?? UIImage()
            )
        case .synced:
            return .image(makeIcon(color: .System.green))
        case .offline, .UNRECOGNIZED:
            return .image(makeIcon(color: .Button.active))
        }
    }
    
    private func makeIcon(color: UIColor, diameter: Double = 8) -> UIImage {
        ImageBuilder(
            ImageGuideline(
                size: CGSize(width: diameter, height: diameter),
                radius: .point(diameter/2)
            )
        )
        .setImageColor(color).build()
    }
}


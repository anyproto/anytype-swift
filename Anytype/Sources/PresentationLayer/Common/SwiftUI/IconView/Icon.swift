import Foundation
import UIKit
import Services

enum Icon: Hashable, Equatable {
    case object(ObjectIcon)
    case asset(ImageAsset)
    case image(UIImage)
}

extension ObjectIcon {
    var icon: Icon {
        return .object(self)
    }
}

extension Icon {
    var imageId: String? {
        switch self {
        case .object(let icon):
            return icon.imageId
        case .asset(_), .image(_):
            return nil
        }
    }
}

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

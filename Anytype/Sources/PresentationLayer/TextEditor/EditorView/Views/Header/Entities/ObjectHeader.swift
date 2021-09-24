import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case iconOnly(ObjectHeaderIcon)
    case coverOnly(ObjectHeaderCover)
    case iconAndCover(icon: ObjectHeaderIcon, cover: ObjectHeaderCover)
    case empty
    
}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case let .iconOnly(objectIcon):
            return ObjectHeaderFilledConfiguration(header: self, width: maxWidth)

        case let .coverOnly(objectCover):
            return ObjectHeaderFilledConfiguration(header: self, width: maxWidth)

        case let .iconAndCover(objectIcon, objectCover):
            return ObjectHeaderFilledConfiguration(header: self, width: maxWidth)
            
        case .empty:
            return ObjectHeaderEmptyConfiguration()
        }
    }
    
}

import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case iconOnly(ObjectIcon)
    case coverOnly(ObjectCover)
    case iconAndCover(icon: ObjectIcon, cover: ObjectCover)
    case empty
    
}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case let .iconOnly(objectIcon):
            return ObjectHeaderIconOnlyConfiguration(icon: objectIcon)
            
        case let .coverOnly(objectCover):
            return ObjectHeaderCoverOnlyConfiguration(
                cover: objectCover,
                maxWidth: maxWidth
            )
            
        case let .iconAndCover(objectIcon, objectCover):
            return ObjectHeaderIconAndCoverConfiguration(
                icon: objectIcon,
                cover: objectCover,
                maxWidth: maxWidth
            )
        case .empty:
            return ObjectHeaderEmptyConfiguration()
        }
    }
    
}

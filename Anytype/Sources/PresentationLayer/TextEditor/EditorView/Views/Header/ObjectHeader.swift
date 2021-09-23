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
            return ObjectHeaderFilledConfiguration(header: self)

        case let .coverOnly(objectCover):
            return ObjectHeaderFilledConfiguration(header: self)

        case let .iconAndCover(objectIcon, objectCover):
            return ObjectHeaderFilledConfiguration(header: self)
            
        case .empty:
            return ObjectHeaderEmptyConfiguration()
        }
    }
    
}

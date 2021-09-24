import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(FilledState)
    case empty
    
}

extension ObjectHeader {
    
    enum FilledState: Hashable {
        case iconOnly(ObjectHeaderIcon)
        case coverOnly(ObjectHeaderCover)
        case iconAndCover(icon: ObjectHeaderIcon, cover: ObjectHeaderCover)
    }

}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState):
            return ObjectHeaderFilledConfiguration(state: filledState, width: maxWidth)
        case .empty:
            return ObjectHeaderEmptyConfiguration()
        }
    }
    
}

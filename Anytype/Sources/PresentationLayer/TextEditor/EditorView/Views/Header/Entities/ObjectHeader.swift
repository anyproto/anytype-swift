import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(FilledState)
    case empty(ObjectHeaderEmptyData)
    
}

extension ObjectHeader {
    
    enum FilledState: Hashable {
        case iconOnly(ObjectHeaderIcon)
        case coverOnly(ObjectHeaderCover)
        case iconAndCover(icon: ObjectHeaderIcon, cover: ObjectHeaderCover)
        
        var isWithCover: Bool {
            switch self {
            case .iconOnly:
                return false
            case .coverOnly:
                return true
            case .iconAndCover:
                return true
            }
        }
    }

}

extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState):
            return ObjectHeaderFilledConfiguration(state: filledState, width: maxWidth)
        case .empty(let data):
            return ObjectHeaderEmptyConfiguration(data: data)
        }
    }
    
}

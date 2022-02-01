import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(ObjectHeaderFilledState)
    case empty(ObjectHeaderEmptyData)
    
}
extension ObjectHeader: ContentConfigurationProvider {
    
    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        switch self {
        case .filled(let filledState):
            return ObjectHeaderFilledConfiguration(state: filledState,
                                                   width: maxWidth)
        case .empty(let data):
            return ObjectHeaderEmptyConfiguration(data: data)
        }
    }
    
}

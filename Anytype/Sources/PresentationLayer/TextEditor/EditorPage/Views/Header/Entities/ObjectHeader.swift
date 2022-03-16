import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case filled(ObjectHeaderFilledState)
    case empty(ObjectHeaderEmptyData)
    
    static var initialState: ObjectHeader {
        .empty(.init(onTap: {}))
    }
}
extension ObjectHeader: ContentConfigurationProvider {
    var indentationLevel: Int { 0 }
    
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

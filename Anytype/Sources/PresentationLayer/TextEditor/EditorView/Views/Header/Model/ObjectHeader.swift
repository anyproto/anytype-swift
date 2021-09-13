import Foundation
import UIKit

enum ObjectHeader: Hashable {
    
    case iconOnly(ObjectIcon)
    case coverOnly(ObjectCover)
    case iconAndCover(icon: ObjectIcon, cover: ObjectCover)
    case empty
    
}

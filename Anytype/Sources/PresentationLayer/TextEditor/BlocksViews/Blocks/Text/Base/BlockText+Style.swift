import Foundation
import Services
import UIKit

extension BlockText {
    
    var defaultBackgroundColor: UIColor? {
        if contentType == .callout {
            return .VeryLight.grey
        }
        
        return nil
    }
}

import Foundation
import UIKit

extension NSAttributedString {
    
    func containsNilAttribute(_ attrName: NSAttributedString.Key, in enumerationRange: NSRange) -> Bool {
        
        var containsNil = false
        
        enumerateAttribute(attrName, in: enumerationRange) { value, range, stop in
            if value.isNil {
                containsNil = true
                stop.pointee = true
            }
        }
        
        return containsNil
    }
    
    func containsNotNilAttribute(_ attrName: NSAttributedString.Key, in enumerationRange: NSRange) -> Bool {
        
        var containsNotNil = false
        
        enumerateAttribute(attrName, in: enumerationRange) { value, range, stop in
            if value.isNotNil {
                containsNotNil = true
                stop.pointee = true
            }
        }
        
        return containsNotNil
    }
}

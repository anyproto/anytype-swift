import Foundation
import UIKit

extension ImageCornersGuideline {
    
    enum Radius {
        /// The radius should be calculated as a fraction of the image width. Typically the associated value should be
        /// between 0 and 0.5, where 0 represents no radius and 0.5 represents using half of the image width.
        case widthFraction(CGFloat)
        case point(CGFloat)
    }
    
}

extension ImageCornersGuideline.Radius {
    
    var identifier: String {
        switch self {
        case .widthFraction(let float):
            return "\(ImageCornersGuideline.Radius.self).widthFraction.\(float)"
        case .point(let float):
            return "\(ImageCornersGuideline.Radius.self).point.\(float)"
        }
    }
    
}

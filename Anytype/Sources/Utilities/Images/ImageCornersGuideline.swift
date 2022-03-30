import UIKit

struct ImageCornersGuideline {
    
    let radius: Radius
    let backgroundColor: UIColor?
    
}

extension ImageCornersGuideline {
    
    var identifier: String {
        """
        \(ImageCornersGuideline.self).
        \(radius.identifier).
        \(backgroundColor?.hexString ?? "")
        """
    }
    
}

import UIKit

struct ImageCornersGuideline {
    
    let radius: Radius
    let borderColor: UIColor?
    
}

extension ImageCornersGuideline {
    
    var identifier: String {
        """
        \(ImageCornersGuideline.self).
        \(radius.identifier).
        \(borderColor?.hexString ?? "")
        """
    }
    
}

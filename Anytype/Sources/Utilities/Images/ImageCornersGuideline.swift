import UIKit

struct ImageCornersGuideline {
    
    let radius: CGFloat
    let borderColor: UIColor?
    
}

extension ImageCornersGuideline {
    
    var isOpaque: Bool {
        guard let backgroundColor = borderColor else { return false }
        
        return !backgroundColor.isTransparent
    }
    
}

extension ImageCornersGuideline {
    
    var identifier: String {
        "\(ImageCornersGuideline.self).\(radius).\(borderColor?.hexString ?? "")"
    }
    
}

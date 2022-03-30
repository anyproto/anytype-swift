import UIKit
import AnytypeCore

struct ImageGuideline {
    
    let size: CGSize
    let cornersGuideline: ImageCornersGuideline?
    
    // MARK: - Initializers
    
    init(size: CGSize, cornersGuideline: ImageCornersGuideline? = nil) {
        if size.isZero {
            anytypeAssertionFailure("Size should not be `zero`", domain: .imageGuideline)
        }
        
        self.size = size
        self.cornersGuideline = cornersGuideline
    }
    
    init(size: CGSize, radius: ImageCornersGuideline.Radius, backgroundColor: UIColor? = nil) {
        if size.isZero {
            anytypeAssertionFailure("Size should not be `zero`", domain: .imageGuideline)
        }
        
        self.size = size
        self.cornersGuideline = ImageCornersGuideline(radius: radius, backgroundColor: backgroundColor)
    }
    
}

extension ImageGuideline {
    
    var cornerRadius: CGFloat {
        guard let radius = cornersGuideline?.radius else { return 0 }
        
        switch radius {
        case .point(let point): return point
        case .widthFraction(let widthFraction):
            return size.width * widthFraction
        }
    }
    
}

extension ImageGuideline {
    
    var identifier: String {
        "\(ImageGuideline.self).\(size).\(cornersGuideline?.identifier ?? "")"
    }
    
}

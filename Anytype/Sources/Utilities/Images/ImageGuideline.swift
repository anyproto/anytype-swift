import UIKit

struct ImageGuideline {
    
    let size: CGSize
    let cornersGuideline: ImageCornersGuideline
    
    // MARK: - Initializers
    
    init(size: CGSize, cornersGuideline: ImageCornersGuideline) {
        self.size = size
        self.cornersGuideline = cornersGuideline
    }
    
    init(size: CGSize,
         cornerRadius: CGFloat? = nil,
         backgroundColor: UIColor? = nil) {
        self.size = size
        self.cornersGuideline = {
            guard let cornerRadius = cornerRadius else {
                return .init(radius: .point(0), borderColor: nil)
            }
            
            return .init(
                radius: .point(cornerRadius),
                borderColor: backgroundColor
            )
        }()
    }
    
}

extension ImageGuideline {
    
    var cornerRadius: CGFloat {
        switch cornersGuideline.radius {
        case .point(let point): return point
        case .widthFraction(let widthFraction):
            return size.width * widthFraction
        }
    }
    
}

extension ImageGuideline {
    
    var identifier: String {
        "\(ImageGuideline.self).\(size).\(cornersGuideline.identifier)"
    }
    
}

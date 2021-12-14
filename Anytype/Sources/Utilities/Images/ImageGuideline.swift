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
                return .init(radius: 0, borderColor: nil)
            }
            
            return .init(
                radius: cornerRadius,
                borderColor: backgroundColor
            )
        }()
    }
    
}

extension ImageGuideline {
    
    var identifier: String {
        "\(ImageGuideline.self).\(size).\(cornersGuideline.identifier)"
    }
    
}

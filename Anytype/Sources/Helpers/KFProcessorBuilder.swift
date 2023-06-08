import Foundation
import Kingfisher
import UIKit

struct KFProcessorBuilder {
    let imageGuideline: ImageGuideline
    let scalingType: KFScalingType?
}

extension KFProcessorBuilder {
    
    func build() -> Kingfisher.ImageProcessor {
        let imageProcessor: ImageProcessor = {
            switch scalingType {
            case .resizing(let mode):
                return ResizingImageProcessor(referenceSize: imageGuideline.size, mode: mode)
                |> CroppingImageProcessor(size: imageGuideline.size)
            case .downsampling:
                return DownsamplingImageProcessor(size: imageGuideline.size)
            case .none:
                return DefaultImageProcessor()
            }
        }()
        
        if let cornersGuideline = imageGuideline.cornersGuideline {
            return imageProcessor |> RoundCornerImageProcessor(
                radius: cornersGuideline.radius.asRoundCornerImageProcessorRadius,
                backgroundColor: nil
            )
        }
        
        return imageProcessor
    }
    
}

private extension ImageCornersGuideline.Radius {
    
    var asRoundCornerImageProcessorRadius: Kingfisher.Radius {
        switch self {
        case .widthFraction(let widthFraction): return .widthFraction(widthFraction)
        case .point(let point): return .point(point)
        }
    }
}


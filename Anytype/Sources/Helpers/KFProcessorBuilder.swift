//
//  KFProcessorBuilder.swift
//  KFProcessorBuilder
//
//  Created by Konstantin Mordan on 30.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

struct KFProcessorBuilder {
    let scalingType: KFScalingType
    let targetSize: CGSize
    let cornerRadius: ImageCornersGuideline.Radius?
}

extension KFProcessorBuilder {
    
    var processor: Kingfisher.ImageProcessor {
        let imageProcessor: ImageProcessor = {
            switch scalingType {
            case .resizing(let mode):
                return ResizingImageProcessor(
                    referenceSize: targetSize,
                    mode: mode
                )
                |> CroppingImageProcessor(size: targetSize)
            case .downsampling:
                return DownsamplingImageProcessor(size: targetSize)
            }
        }()
        
        if let cornerRadius = cornerRadius {
            return imageProcessor |> RoundCornerImageProcessor(radius: cornerRadius.asRoundCornerImageProcessorRadius)
        } else {
            return imageProcessor
        }
    }
    
}

private extension ImageCornersGuideline.Radius {
    
    var asRoundCornerImageProcessorRadius: RoundCornerImageProcessor.Radius {
        switch self {
        case .widthFraction(let widthFraction): return .widthFraction(widthFraction)
        case .point(let point): return .point(point)
        }
    }
}

//
//  AnytypeImageViewWrapper.swift
//  Anytype
//
//  Created by Konstantin Mordan on 30.03.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    
    var wrapper: AnytypeImageViewWrapper {
        AnytypeImageViewWrapper(imageView: self)
    }
    
}

final class AnytypeImageViewWrapper {
    
    private var imageGuideline: ImageGuideline?
    private var scalingType: KFScalingType = .resizing(.aspectFill)
    private var animatedTransition = false
    private var placeholderNeeded = true
    
    private let imageView: UIImageView
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
}

extension AnytypeImageViewWrapper {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> AnytypeImageViewWrapper {
        self.imageGuideline = imageGuideline
        return self
    }
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType) -> AnytypeImageViewWrapper {
        self.scalingType = scalingType
        return self
    }
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> AnytypeImageViewWrapper {
        self.animatedTransition = animatedTransition
        return self
    }
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> AnytypeImageViewWrapper {
        self.placeholderNeeded = placeholderNeeded
        return self
    }
    
    func setImage(id: String) {
        guard id.isNotEmpty else {
            // TODO: assert
            return
        }
        
        guard let imageGuideline = imageGuideline else {
            // TODO: assert
            return
        }
        
        guard
            let url = ImageMetadata(id: id, width: imageGuideline.size.width.asImageWidth).contentUrl
        else {
            // TODO: assert
            return
        }
        
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(
            with: url,
            placeholder: buildPlaceholder(with: imageGuideline),
            options: buildOptions(with: imageGuideline)
        ) { result in
            // TODO: assert
        }
    }
    
}

private extension AnytypeImageViewWrapper {
    
    func buildPlaceholder(with imageGuideline: ImageGuideline) -> Placeholder? {
        placeholderNeeded ? ImageBuilder(imageGuideline).build() : nil
    }
    
    func buildOptions(with imageGuideline: ImageGuideline) -> KingfisherOptionsInfo {
        let processor = buildProcessor(imageGuideline: imageGuideline)
        
        var options: KingfisherOptionsInfo = [.processor(processor)]
        if animatedTransition {
            options.append(.transition(.fade(0.2)))
        }
        
        return options
    }
    
    func buildProcessor(imageGuideline: ImageGuideline) -> Kingfisher.ImageProcessor {
        let imageProcessor: ImageProcessor = {
            switch scalingType {
            case .resizing(let mode):
                return ResizingImageProcessor(referenceSize: imageGuideline.size, mode: mode)
                |> CroppingImageProcessor(size: imageGuideline.size)
            case .downsampling:
                return DownsamplingImageProcessor(size: imageGuideline.size)
            }
        }()
        
//        if let cornerRadius = cornerRadius {
//            return imageProcessor |> RoundCornerImageProcessor(radius: cornerRadius)
//        } else {
//            return imageProcessor
//        }
        
        return imageProcessor
    }
    
}

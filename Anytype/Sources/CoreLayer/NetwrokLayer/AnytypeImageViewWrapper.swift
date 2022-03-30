import Foundation
import UIKit
import Kingfisher
import AnytypeCore

final class AnytypeImageViewWrapper {
    
    private var imageGuideline: ImageGuideline?
    private var scalingType: KFScalingType = .resizing(.aspectFill)
    private var animatedTransition = true
    private var placeholderNeeded = true
    
    private let imageView: UIImageView
    
    // MARK: - Initializers
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
}

// MARK: - Public functions

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
        imageView.kf.cancelDownloadTask()
        
        guard id.isNotEmpty else {
            anytypeAssertionFailure(<#T##message: String##String#>, domain: ErrorDomain)
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
        
        setImage(url: url)
    }
    
    func setImage(url: URL) {
        imageView.kf.cancelDownloadTask()
        
        guard let imageGuideline = imageGuideline else {
            // TODO: assert
            return
        }
        
        imageView.kf.setImage(
            with: url,
            placeholder: buildPlaceholder(with: imageGuideline),
            options: buildOptions(with: imageGuideline)
        ) { result in
            // TODO: assert
        }
    }
    
    func setImage(_ image: UIImage?) {
        imageView.kf.cancelDownloadTask()
        imageView.image = image
    }
    
}

// MARK: - Private extension

private extension AnytypeImageViewWrapper {
    
    func buildPlaceholder(with imageGuideline: ImageGuideline) -> Placeholder? {
        placeholderNeeded ? ImageBuilder(imageGuideline).build() : nil
    }
    
    func buildOptions(with imageGuideline: ImageGuideline) -> KingfisherOptionsInfo {
        let processor = KFProcessorBuilder(imageGuideline: imageGuideline, scalingType: scalingType).build() 
        
        var options: KingfisherOptionsInfo = [.processor(processor)]
        if animatedTransition {
            options.append(.transition(.fade(0.2)))
        }
        
        return options
    }
    
}

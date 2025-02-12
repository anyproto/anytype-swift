import Foundation
import UIKit
import Kingfisher
import AnytypeCore

@MainActor
final class DownloadableImageViewWrapper: DownloadableImageViewWrapperProtocol {
    
    private var imageGuideline: ImageGuideline?
    private var scalingType: KFScalingType? = .resizing(.aspectFill)
    private var animatedTransition = true
    private var placeholderNeeded = true
    
    private let imageView: UIImageView
    
    // MARK: - Initializers
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    // MARK: - DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> any DownloadableImageViewWrapperProtocol {
        self.imageGuideline = imageGuideline
        return self
    }
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType?) -> any DownloadableImageViewWrapperProtocol {
        self.scalingType = scalingType
        return self
    }
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> any DownloadableImageViewWrapperProtocol {
        self.animatedTransition = animatedTransition
        return self
    }
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> any DownloadableImageViewWrapperProtocol {
        self.placeholderNeeded = placeholderNeeded
        return self
    }
    
    func setImage(id: String) {
        imageView.kf.cancelDownloadTask()
        
        guard id.isNotEmpty else {
            anytypeAssertionFailure("Empty image id")
            return
        }
             
        guard let imageGuideline = imageGuideline else {
            anytypeAssertionFailure("ImageGuideline is nil")
            return
        }
        
        let imageMetadata = ImageMetadata(id: id, width: imageGuideline.size.width)
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil")
            return
        }
        
        setImage(url: url)
    }
    
    func setImage(url: URL) {
        imageView.kf.cancelDownloadTask()
        
        guard let imageGuideline = imageGuideline else {
            anytypeAssertionFailure("ImageGuideline is nil")
            return
        }
        
        imageView.kf.setImage(
            with: url,
            placeholder: buildPlaceholder(with: imageGuideline),
            options: buildOptions(with: imageGuideline)
        )
    }
    
    func setImage(_ image: UIImage?) {
        imageView.kf.cancelDownloadTask()
        imageView.image = image
    }
    
}

// MARK: - Private extension

private extension DownloadableImageViewWrapper {
    
    func buildPlaceholder(with imageGuideline: ImageGuideline) -> (some Placeholder)? {
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

import Foundation
import UIKit
import Kingfisher
import AnytypeCore

final class DownloadableImageViewWrapper {
    
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

extension DownloadableImageViewWrapper: DownloadableImageViewWrapperProtocol {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> DownloadableImageViewWrapperProtocol {
        self.imageGuideline = imageGuideline
        return self
    }
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType) -> DownloadableImageViewWrapperProtocol {
        self.scalingType = scalingType
        return self
    }
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> DownloadableImageViewWrapperProtocol {
        self.animatedTransition = animatedTransition
        return self
    }
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> DownloadableImageViewWrapperProtocol {
        self.placeholderNeeded = placeholderNeeded
        return self
    }
    
    func setImage(id: String) {
        imageView.kf.cancelDownloadTask()
        
        guard id.isNotEmpty else {
            anytypeAssertionFailure("Empty image id", domain: .imageViewWrapper)
            return
        }
             
        guard let imageGuideline = imageGuideline else {
            anytypeAssertionFailure("ImageGuideline is nil", domain: .imageViewWrapper)
            return
        }
        
        let imageMetadata = ImageMetadata(id: id, width: imageGuideline.size.width)
        guard let url = imageMetadata.contentUrl else {
            anytypeAssertionFailure("Url is nil", domain: .imageViewWrapper)
            return
        }
        
        setImage(url: url)
    }
    
    func setImage(url: URL) {
        imageView.kf.cancelDownloadTask()
        
        guard let imageGuideline = imageGuideline else {
            anytypeAssertionFailure("ImageGuideline is nil", domain: .imageViewWrapper)
            return
        }
        
        imageView.kf.setImage(
            with: url,
            placeholder: buildPlaceholder(with: imageGuideline),
            options: buildOptions(with: imageGuideline)
        ) { result in
            guard
                case .failure(let error) = result,
                !error.isTaskCancelled,
                !error.isImageSettingError
            else { return }
 
            anytypeAssertionFailure(error.localizedDescription, domain: .imageViewWrapper)
        }
    }
    
    func setImage(_ image: UIImage?) {
        imageView.kf.cancelDownloadTask()
        imageView.image = image
    }
    
}

// MARK: - Private extension

private extension DownloadableImageViewWrapper {
    
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

private extension KingfisherError {
    
    var isImageSettingError: Bool {
        if case .imageSettingError = self { return true }
        return false
    }
    
}

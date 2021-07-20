import Foundation
import UIKit
import Combine

final class ImageLoader {
    weak var imageView: UIImageView?
    
    private var subscription: AnyCancellable?
    private var property: ImageProperty?
    
    var image: UIImage? {
        property?.property
    }
    
    init(imageView: UIImageView? = nil) {
        self.imageView = imageView
    }
    
    func update(
        imageId hash: String,
        parameters: ImageParameters = .init(width: .default),
        placeholder: UIImage? = nil
    ) {
        property = ImageProperty(imageId: hash, parameters)
        if let image = image {
            setImage(image: image)
            return
        }
        
        imageView?.image = placeholder
        imageView?.contentMode = .center
        
        subscription = property?.stream
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] image in
                self?.setImage(image: image)
            }
    }
    
    func cleanupSubscription() {
        subscription = nil
    }
    
    private func setImage(image: UIImage) {
        imageView?.contentMode = isImageLong(image: image) ? .scaleAspectFit : .scaleAspectFill
        imageView?.image = image
    }
    
    private func isImageLong(image: UIImage) -> Bool {
        if image.size.height / image.size.width > 3 {
            return true
        }
        
        if image.size.width / image.size.height > 3 {
            return true
        }
        
        return false
    }
}

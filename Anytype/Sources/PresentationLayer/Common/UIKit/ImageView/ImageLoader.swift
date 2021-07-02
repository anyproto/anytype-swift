import Foundation
import UIKit
import Combine

final class ImageLoader {
    /// Variables
    private var subscription: AnyCancellable?
    private weak var imageView: UIImageView?
    private var property: ImageProperty?
    
    var image: UIImage? {
        property?.property
    }
    
    /// Configuration
    @discardableResult
    func configured(_ imageView: UIImageView?) -> Self {
        self.imageView = imageView
        
        return self
    }
    
    /// Update
    func update(
        imageId hash: String,
        parameters: ImageParameters = .init(width: .default),
        placeholder: UIImage? = nil
    ) {
        property = ImageProperty(imageId: hash, parameters)
        
        if let image = property?.property {
            imageView?.image = image
            return
        }
        
        imageView?.image = placeholder
        subscription = property?.stream
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sink { [weak self] value in
                self?.imageView?.image = value
            }
    }
    
    /// Cleanup
    func cleanupSubscription() {
        subscription = nil
    }
}

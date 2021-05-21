import Foundation
import UIKit
import Combine

final class ImageLoader {
    /// Variables
    private var subscription: AnyCancellable?
    private weak var imageView: UIImageView?
    private var property: ImageProperty?
    
    /// Configuration
    @discardableResult
    func configured(_ imageView: UIImageView?) -> Self {
        self.imageView = imageView
        
        return self
    }
    
    /// Update
    func update(imageId hash: String, parameters: ImageParameters = .init(width: .default)) {
        self.property = ImageProperty(imageId: hash, .init(width: .default))
        
        if let image = self.property?.property {
            self.imageView?.image = image
            return
        }
        
        self.imageView?.image = nil
        self.subscription = self.property?.stream.receiveOnMain().sink { [weak self] (value) in
            self?.imageView?.image = value
        }
    }
    
    /// Cleanup
    func cleanupSubscription() {
        self.subscription = nil
    }
}

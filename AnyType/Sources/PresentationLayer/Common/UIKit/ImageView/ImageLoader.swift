import Foundation
import UIKit
import Combine

class ImageLoader {
    /// Variables
    private var subscription: AnyCancellable?
    private weak var imageView: UIImageView?
    private var property: ImageProperty?
    
    /// Configuration
    func configured(_ imageView: UIImageView?) {
        self.imageView = imageView
    }
    
    /// Update
    func update(imageId hash: String, parameters: ImageParameters = .init(width: .default)) {
        self.property = .init(imageId: hash, .init(width: .default))
        
        if let image = self.property?.property {
            self.imageView?.image = image
            return
        }
        
        self.imageView?.image = nil
        self.subscription = self.property?.stream.reciveOnMain().sink { [weak self] (value) in
            self?.imageView?.image = value
            //                    self?.updateImageConstraints()
        }
    }
    
    /// Cleanup
    func cleanupSubscription() {
        self.subscription = nil
    }
}

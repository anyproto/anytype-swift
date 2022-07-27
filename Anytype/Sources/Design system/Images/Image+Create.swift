import Foundation
import UIKit
import SwiftUI
import AnytypeCore

extension UIImage {
    convenience init?(asset: ImageAsset) {
        switch asset {
        case let .bundle(name):
            self.init(named: name, in: BundleToken.bundle, compatibleWith: nil)
        case let .system(name):
            self.init(systemName: name)
        }
        
    }
    
    static func from(asset: ImageAsset) -> UIImage {
        guard let image = UIImage(asset: asset) else {
            anytypeAssertionFailure("No image named: \(asset)", domain: .imageCreation)
            return UIImage()
        }
        return image
    }
}

extension UIImageView {
    convenience init(asset: ImageAsset) {
        let image = UIImage(asset: asset)
        self.init(image: image)
    }
}

extension Image {
    init(asset: ImageAsset) {
        switch asset {
        case let .bundle(name):
            self.init(name, bundle: BundleToken.bundle)
        case let .system(name):
            self.init(systemName: name)
        }
        
    }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

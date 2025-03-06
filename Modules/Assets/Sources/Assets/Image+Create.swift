import Foundation
import UIKit
import SwiftUI

public extension UIImage {
    convenience init?(asset: ImageAsset) {
        switch asset {
        case let .bundle(name):
            self.init(named: name, in: BundleToken.bundle, compatibleWith: nil)
        case let .system(name):
            self.init(systemName: name)
        }
        
    }
}

public extension UIImageView {
    convenience init(asset: ImageAsset) {
        let image = UIImage(asset: asset)
        self.init(image: image)
    }
}

public extension Image {
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

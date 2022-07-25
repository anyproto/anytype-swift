import Foundation
import UIKit
import SwiftUI
import AnytypeCore

extension UIImage {
    convenience init?(asset: ImageAsset) {
        self.init(named: asset.name, in: BundleToken.bundle, compatibleWith: nil)
    }
    
    static func from(asset: ImageAsset) -> UIImage {
        guard let image = UIImage(asset: asset) else {
            anytypeAssertionFailure("No image named: \(asset.name)", domain: .imageCreation)
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
        self.init(asset.name, bundle: BundleToken.bundle)
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

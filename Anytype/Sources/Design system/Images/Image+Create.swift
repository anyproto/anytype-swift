import Foundation
import UIKit
import SwiftUI
import AnytypeCore

extension UIImage {
    static func from(asset: ImageAsset) -> UIImage {
        guard let image = UIImage(named: asset.name, in: BundleToken.bundle, compatibleWith: nil) else {
            anytypeAssertionFailure("No image named: \(asset.name)", domain: .imageCreation)
            return UIImage()
        }
        return image
    }
}

extension UIImageView {
    convenience init(asset: ImageAsset) {
        let image = UIImage.from(asset: asset)
        self.init(image: image)
    }
}

extension Image {
    init(asset: ImageAsset) {
        self.init(asset.name, bundle: BundleToken.bundle)
    }
}


// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

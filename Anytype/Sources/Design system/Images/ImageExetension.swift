import SwiftUI
import AnytypeCore
import BlocksModels

extension ImageAsset {
    static let multiplyCircleFill = ImageAsset.system(name: "multiply.circle.fill")
}

extension Image {
    static let appIcon = createImage("AppIcon")
    static let oldSchoolAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "oldSchool")) 
    static let artAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "art"))
}


extension Image {
    static func createImage(_ name: String) -> Image {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)", domain: .imageCreation)
            return Image(asset: .noImage)
        }
        
        return Image(uiImage: image)
    }
}

extension ImageAsset {
    var identifier: String {
        switch self {
        case let .bundle(name):
            return name
        case let .system(name):
            return name
        }
    }
}

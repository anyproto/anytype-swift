import SwiftUI
import AnytypeCore
import BlocksModels

extension ImageAsset {
    static let multiplyCircleFill = ImageAsset.system(name: "multiply.circle.fill")
}

extension Image {
    static let appIcon = Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
    static let oldSchoolAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "oldSchool")) 
    static let artAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "art"))
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

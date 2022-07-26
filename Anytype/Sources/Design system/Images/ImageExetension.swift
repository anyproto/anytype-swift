import SwiftUI
import AnytypeCore
import BlocksModels

struct SystemImageAsset {
    let name: String
}

extension SystemImageAsset {
    static let multiplyCircleFill = SystemImageAsset(name: "multiply.circle.fill")
}

extension Image {
    static let oldSchoolAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "oldSchool")) 
    static let artAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "art"))
}

import SwiftUI
import AnytypeCore
import Services

extension ImageAsset {
    static let multiplyCircleFill = ImageAsset.system(name: "multiply.circle.fill")
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

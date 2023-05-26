import Foundation
import UIKit

extension UIUserInterfaceStyle: Identifiable {
    public var id: Int { rawValue }

    static var allCases: [UIUserInterfaceStyle] { [.light, .dark, .unspecified,] }

    var title: String {
        switch self {
        case .light:
            return Loc.InterfaceStyle.light
        case .dark:
            return Loc.InterfaceStyle.dark
        case .unspecified:
            fallthrough
        @unknown default:
            return Loc.InterfaceStyle.system
        }
    }

    var imageAsset: ImageAsset {
        switch self {
        case .light:
            return .Settings.Theme.light
        case .dark:
            return .Settings.Theme.dark
        case .unspecified:
            fallthrough
        @unknown default:
            return .Settings.Theme.system
        }
    }
}

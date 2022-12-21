import UIKit
import BlocksModels

extension ComponentColor where T: UIColor {
    static func uiColor(from middlewareColor: MiddlewareColor) -> UIColor {
        switch middlewareColor {
        case .default: return `default`
        case .grey: return grey
        case .yellow: return yellow
        case .orange: return amber
        case .red: return red
        case .pink: return pink
        case .purple: return purple
        case .blue: return blue
        case .ice: return sky
        case .teal: return teal
        case .lime: return green
        }
    }
}

extension UIColor {
    func middlewareString(background: Bool) -> String? {
        MiddlewareColor.allCases.first(
            where: { middleware in
                UIColor.Text.uiColor(from: middleware) == self ||
                UIColor.VeryLight.uiColor(from: middleware) == self ||
                UIColor.TagBackground.uiColor(from: middleware) == self
            }
        )?.rawValue
    }
}

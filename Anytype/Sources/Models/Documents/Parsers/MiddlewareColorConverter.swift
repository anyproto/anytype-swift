import UIKit
import BlocksModels

extension MiddlewareColor {
    func color(background: Bool) -> UIColor {
        switch self {
        case .default: return background ? .backgroundPrimary : .textPrimary
        case .grey: return background ? .lightGray : .darkGray
        case .yellow: return background ? .lightLemon : .pureLemon
        case .orange: return background ? .lightAmber : .pureAmber
        case .red: return background ? .lightRed : .pureRed
        case .pink: return background ? .lightPink : .purePink
        case .purple: return background ? .lightPurple : .purePurple
        case .blue: return background ? .lightUltramarine : .pureUltramarine
        case .ice: return background ? .lightBlue : .pureBlue
        case .teal: return background ? .lightTeal : .pureTeal
        case .lime: return background ? .lightGreen : .pureGreen
        }
    }
}

extension UIColor {
    func middlewareString(background: Bool) -> String? {
        MiddlewareColor.allCases.first(
            where: { middleware in
                middleware.color(background: background) == self
            }
        )?.rawValue
    }
}

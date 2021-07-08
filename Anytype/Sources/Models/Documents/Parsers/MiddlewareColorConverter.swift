import UIKit
import BlocksModels

extension MiddlewareColor {    
    func color(background: Bool) -> UIColor {
        switch self {
        case .default: return background ? .grayscaleWhite : .grayscale90
        case .grey: return background ? .lightColdGray : .darkColdGray
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
    
    static func name(_ color: UIColor, background: Bool = false) -> String? {
        allCases.first(where: {$0.color(background: background) == color})?.name()
    }
}

enum MiddlewareColorConverter {
    static func asString(_ color: UIColor, background: Bool) -> String? {
        MiddlewareColor.name(color, background: background)
    }
    
    static func asMiddleware(_ backgroundColor: BlockBackgroundColor) -> MiddlewareColor? {
        MiddlewareColor.allCases.first(where: {$0.color(background: true) == backgroundColor.color})
    }
    
    static func asMiddleware(_ color: BlockColor) -> MiddlewareColor? {
        MiddlewareColor.allCases.first(where: {$0.color(background: false) == color.color})
    }
}

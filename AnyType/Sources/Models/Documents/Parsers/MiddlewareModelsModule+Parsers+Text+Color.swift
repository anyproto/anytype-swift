import Foundation
import UIKit
import os

enum MiddlewareColor {
    case `default`, grey, yellow, orange, red, pink, purple, blue, ice, teal, lime

    init?(name: String) {
        guard let value = Self.allCases.first(where: {$0.name() == name}) else {
            return nil
        }
        self = value
    }

    init?(color: UIColor) {
        guard let colorName = Self.name(color) else { return nil }
        self.init(name: colorName)
    }

    func color(background: Bool = false) -> UIColor {
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

    func name() -> String {
        switch self {
        case .default: return "default"
        case .grey: return "grey"
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .red: return "red"
        case .pink: return "pink"
        case .purple: return "purple"
        case .blue: return "blue"
        case .ice: return "ice"
        case .teal: return "teal"
        case .lime: return "lime"
        }
    }

    static func name(_ color: UIColor, background: Bool = false) -> String? {
        allCases.first(where: {$0.color(background: background) == color})?.name()
    }

    static let allCases: [MiddlewareColor] = [.default, .grey, .yellow, .orange, .red, .pink, .purple, .blue, .ice, .teal, .lime]
}

enum MiddlewareColorConverter {
    static func asModel(_ name: String, background: Bool = false) -> UIColor? {
        MiddlewareColor(name: name)?.color(background: background)
    }

    static func asMiddleware(_ color: UIColor, background: Bool = false) -> String? {
        MiddlewareColor.name(color, background: background)
    }
}

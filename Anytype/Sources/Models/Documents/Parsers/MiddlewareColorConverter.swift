import UIKit
import Services
import SwiftUI

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
    func middlewareColor() -> MiddlewareColor? {
        MiddlewareColor.allCases.first(
            where: { middleware in
                UIColor.Dark.uiColor(from: middleware) == self ||
                UIColor.VeryLight.uiColor(from: middleware) == self ||
                UIColor.Light.uiColor(from: middleware) == self
            }
        )
    }
    
    func middlewareString() -> String? {
        middlewareColor()?.rawValue
    }
}

extension ComponentColor where T == Color {
    static func color(from middlewareColor: MiddlewareColor) -> Color {
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

extension Color {
    func middlewareColor() -> MiddlewareColor? {
        MiddlewareColor.allCases.first(
            where: { middleware in
                Color.Dark.color(from: middleware) == self ||
                Color.VeryLight.color(from: middleware) == self ||
                Color.Light.color(from: middleware) == self
            }
        )
    }
    
    func middlewareString() -> String? {
        middlewareColor()?.rawValue
    }
    
    func veryLightColor() -> Color {
        middlewareColor().map { Color.VeryLight.color(from: $0) } ?? Color.VeryLight.grey
    }
}

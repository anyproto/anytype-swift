import Foundation
import UIKit
import os

fileprivate typealias Namespace = MiddlewareModelsModule.Parsers.Text

extension Namespace.Color {
    /// This is Converter between our high-level `UIColor` representation of color and middleware color names as String.
    ///
    /// In API you will see nullable parameters.
    enum Converter {
        enum Colors: CaseIterable {
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
                case .default: return background ? .defaultBackgroundColor : .black
                case .grey: return background ? .coldgrayBackground : .coldgray
                case .yellow: return background ? .lemonBackground : .lemon
                case .orange: return background ? .amberBackground : .amber
                case .red: return background ? .redBackground : .red
                case .pink: return background ? .pinkBackground : .pink
                case .purple: return background ? .purpleBackground : .purple
                case .blue: return background ? .ultramarineBackground : .ultramarine
                case .ice: return background ? .blueBackground : .blue
                case .teal: return background ? .tealBackground : .teal
                case .lime: return background ? .greenBackground : .green
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

            static let allCases: [Colors] = [.default, .grey, .yellow, .orange, .red, .pink, .purple, .blue, .ice, .teal, .lime]
        }

        /// Convert middlware color to UIColor.
        static func asModel(_ name: String, background: Bool = false) -> UIColor? {
            Colors(name: name)?.color(background: background)
        }

        /// Convert UIColor to middlware color.
        static func asMiddleware(_ color: UIColor, background: Bool = false) -> String? {
            Colors.name(color, background: background)
        }
    }
}

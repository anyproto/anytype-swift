//
//  MiddlewareModelsModule+Parsers+Text+Color.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import os

fileprivate typealias Namespace = MiddlewareModelsModule.Parsers.Text

private extension Logging.Categories {
    static let middlewareModelsModuleParsersTextColor: Self = "MiddlewareModelsModule.Parsers.Text.Color"
}

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
                case .default: return background ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.1725490196, green: 0.168627451, blue: 0.1529411765, alpha: 1) // #2C2B27 #FFFFFF
                case .grey: return background ? #colorLiteral(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) : #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1) // #ACA996 #F3F2EC
                case .yellow: return background ? #colorLiteral(red: 0.996, green: 0.976, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.8509803922, blue: 0.1058823529, alpha: 1) // #ECD91B #FEF9CC
                case .orange: return background ? #colorLiteral(red: 0.996, green: 0.953, blue: 0.773, alpha: 1) : #colorLiteral(red: 1, green: 0.7098039216, blue: 0.1333333333, alpha: 1) // #FFB522 #FEF3C5
                case .red: return background ? #colorLiteral(red: 1, green: 0.922, blue: 0.898, alpha: 1) : #colorLiteral(red: 0.9607843137, green: 0.3333333333, blue: 0.1333333333, alpha: 1) // #F55522 #FFEBE5
                case .pink: return background ? #colorLiteral(red: 0.9989849925, green: 0.9155611396, blue: 0.9688507915, alpha: 1): #colorLiteral(red: 0.9284457564, green: 0.2423266172, blue: 0.6887030005, alpha: 1) // #E51CA0 #FEE3F5
                case .purple: return background ? #colorLiteral(red: 0.957, green: 0.891, blue: 0.98, alpha: 1) : #colorLiteral(red: 0.6705882353, green: 0.3137254902, blue: 0.8, alpha: 1) // #AB50CC #F4E3FA
                case .blue: return background ? #colorLiteral(red: 0.9149041772, green: 0.9267032743, blue: 0.9909015298, alpha: 1): #colorLiteral(red: 0.2431372549, green: 0.3450980392, blue: 0.9215686275, alpha: 1) // #3E58EB #E4E7FC
                case .ice: return background ? #colorLiteral(red: 0.8679508567, green: 0.9499784112, blue: 0.9940564036, alpha: 1): #colorLiteral(red: 0.1647058824, green: 0.6549019608, blue: 0.9333333333, alpha: 1) // #2AA7EE #D6EFFD
                case .teal: return background ? #colorLiteral(red: 0.8673310876, green: 0.9668391347, blue: 0.9626916051, alpha: 1): #colorLiteral(red: 0.05882352941, green: 0.7843137255, blue: 0.7294117647, alpha: 1) // #0FC8BA #D6F5F3
                case .lime: return background ? #colorLiteral(red: 0.9100281, green: 0.9701840281, blue: 0.8502092957, alpha: 1) : #colorLiteral(red: 0.3975118399, green: 0.8001303673, blue: 0, alpha: 1) // #57C600 #E3F7D0
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

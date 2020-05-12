//
//  BlockModel+Parser+Text+Color.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import os

private extension Logging.Categories {
    static let blockModelsParserTextColor: Self = "BlockModels.Parser.Text.Color"
}

extension BlockModels.Parser.Text.Color {
    /// This is Converter between our high-level `UIColor` representation of color and middleware color names as String.
    /// 
    /// In API you will see nullable parameters.
    /// It is intentional, we could use `default` options by passing `nil` as a value.
    ///
    enum Converter {
        enum Colors: CaseIterable {
            case `default`, grey, yellow, orange, red, magenta, purple, ultramarine, lightBlue, teal, green
            func color(background: Bool = false) -> UIColor {
                switch self {
                case .default: return background ? .clear : .black
                case .grey: return background ? #colorLiteral(red: 0.953, green: 0.949, blue: 0.925, alpha: 1) : #colorLiteral(red: 0.6745098039, green: 0.662745098, blue: 0.5882352941, alpha: 1) // #ACA996
                case .yellow: return background ? #colorLiteral(red: 0.996, green: 0.976, blue: 0.8, alpha: 1) : #colorLiteral(red: 0.9254901961, green: 0.8509803922, blue: 0.1058823529, alpha: 1) // #ECD91B
                case .orange: return background ? #colorLiteral(red: 0.996, green: 0.953, blue: 0.773, alpha: 1) : #colorLiteral(red: 1, green: 0.7098039216, blue: 0.1333333333, alpha: 1) // #FFB522
                case .red: return background ? #colorLiteral(red: 1, green: 0.922, blue: 0.898, alpha: 1) : #colorLiteral(red: 0.9607843137, green: 0.3333333333, blue: 0.1333333333, alpha: 1) // #F55522
                case .magenta: return background ? #colorLiteral(red: 0.996, green: 0.89, blue: 0.961, alpha: 1) : #colorLiteral(red: 0.8980392157, green: 0.1098039216, blue: 0.6274509804, alpha: 1) // #E51CA0
                case .purple: return background ? #colorLiteral(red: 0.957, green: 0.891, blue: 0.98, alpha: 1) : #colorLiteral(red: 0.6705882353, green: 0.3137254902, blue: 0.8, alpha: 1) // #AB50CC
                case .ultramarine: return background ? #colorLiteral(red: 0.894, green: 0.906, blue: 0.988, alpha: 1) : #colorLiteral(red: 0.2431372549, green: 0.3450980392, blue: 0.9215686275, alpha: 1) // #3E58EB
                case .lightBlue: return background ? #colorLiteral(red: 0.84, green: 0.937, blue: 0.992, alpha: 1) : #colorLiteral(red: 0.1647058824, green: 0.6549019608, blue: 0.9333333333, alpha: 1) // #2AA7EE
                case .teal: return background ? #colorLiteral(red: 0.839, green: 0.961, blue: 0.953, alpha: 1) : #colorLiteral(red: 0.05882352941, green: 0.7843137255, blue: 0.7294117647, alpha: 1) // #0FC8BA
                case .green: return background ? #colorLiteral(red: 0.89, green: 0.969, blue: 0.816, alpha: 1) :  #colorLiteral(red: 0.3647058824, green: 0.831372549, blue: 0, alpha: 1) // #5DD400
                }
            }

            init(name: String) {
                if let value = Self.allCases.first(where: {$0.name() == name}) {
                    self = value
                }
                else {
                    let logger = Logging.createLogger(category: .blockModelsParserTextColor)
                    os_log(.debug, log: logger, "Somehow we can't find a name: %@, so we set it to %@", name, String(describing: Colors.default))
                    self = .default
                }
            }

            func name() -> String {
                switch self {
                case .default: return "default"
                case .grey: return "grey"
                case .yellow: return "yellow"
                case .orange: return "orange"
                case .red: return "red"
                case .magenta: return "magenta"
                case .purple: return "purple"
                case .ultramarine: return "ultramarine"
                case .lightBlue: return "lightBlue"
                case .teal: return "teal"
                case .green: return "green"
                }
            }

            static func name(_ color: UIColor, background: Bool = false) -> String {
                allCases.first(where: {$0.color(background: background) == color})?.name() ?? Colors.default.name()
            }

            static let allCases: [Colors] = [.default, .grey, .yellow, .orange, .red, .magenta, .purple, .ultramarine, .lightBlue, .teal, .green]
        }

        /// Actually, we could set color name to nil.
        /// But that shouldn't be true?
        ///
        static func asModel(_ name: String?, background: Bool = false) -> UIColor {
            name.flatMap(Colors.init(name:))?.color(background: background) ?? Colors.default.color(background: background)
        }

        /// Actually, we could set color to nil.
        /// In this case we should send to middle default value.
        ///
        static func asMiddleware(_ color: UIColor?, background: Bool = false) -> String {
            color.flatMap({Colors.name($0, background: background)}) ?? Colors.default.name()
        }
    }
}

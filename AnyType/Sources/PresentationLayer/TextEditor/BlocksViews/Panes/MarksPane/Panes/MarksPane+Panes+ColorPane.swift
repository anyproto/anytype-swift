//
//  MarksPane+Panes+ColorPane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

extension MarksPane.Panes {
    enum Color {}
}

// MARK: Colors
extension MarksPane.Panes.Color {
    typealias Colors = MiddlewareModelsModule.Parsers.Text.Color.Converter.Colors
    typealias ColorsConverter = MiddlewareModelsModule.Parsers.Text.Color.Converter
}

// MARK: States and Actions
extension MarksPane.Panes.Color {
    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    ///
    enum Converter {
        private static func state(_ style: BlockTextView.MarkStyle, background: Bool) -> UIColor? {
            switch style {
            case let .textColor(color): return color ?? .defaultColor
            case let .backgroundColor(color): return color ?? .grayscaleWhite
            default: return nil
            }
        }
        
        static func state(_ style: BlockTextView.MarkStyle?, background: Bool) -> UIColor? {
            style.flatMap({state($0, background: background)})
        }
        
        static func states(_ styles: [BlockTextView.MarkStyle], background: Bool) -> [UIColor] {
            styles.compactMap({state($0, background: background)})
        }
    }
}

//
//  MarksPane+Panes+StylePane+FontStyleModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// MARK: Style Pane / Font Style
extension MarksPane.Panes.StylePane {
    enum FontStyle {}
}

extension MarksPane.Panes.StylePane.FontStyle {

    enum Attribute {
        case bold(Bool)
        case italic(Bool)
        case strikethrough(Bool)
        case keyboard(Bool)
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    ///
    enum Converter {
        private static func state(_ style: BlockTextView.MarkStyle) -> Attribute? {
            switch style {
            case let .bold(value): return .bold(value)
            case let .italic(value): return .italic(value)
            case let .strikethrough(value): return .strikethrough(value)
            case let .keyboard(value): return .keyboard(value)
            default: return nil
            }
        }

        static func state(_ style: BlockTextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }

        static func states(_ styles: [BlockTextView.MarkStyle]) -> [Attribute] {
            styles.compactMap(state)
        }
    }
}

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

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension MarksPane.Panes.StylePane.FontStyle {
    /// An `Attribute` from UserResponse.
    /// When user press something in related UI component, you should update state of this UI component.
    /// For us, it is a selection of UITextView.
    ///
    /// So, we receive attributes from selection of UITextView.
    ///
    /// This attribute refers to this update.
    ///
    /// That is why you have `Converter` from `TextView.MarkStyle`
    ///
    enum Attribute: CaseIterable {
        case bold(Bool)
        case italic(Bool)
        case strikethrough(Bool)
        case keyboard(Bool)

        /// As soon as we have Inclusive `Attribute` ( a `Set` of attributes )
        /// We should be able to find attributes of the same kind.
        /// For that reason we have `allCases` with empty state.
        ///
        static var allCases: [Attribute] = [ .bold(false), .italic(false), .strikethrough(false), .keyboard(false) ]

        var boolValue: Bool {
            switch self {
            case let .bold(value): return value
            case let .italic(value): return value
            case let .strikethrough(value): return value
            case let .keyboard(value): return value
            }
        }

        /// This is a Kind of attribute.
        /// Actually, we have a Set of `Attributes`.
        /// For that reason, we should find an attribute of the same `kind`.
        /// This is helper struct for this.
        ///
        struct Kind {
            var attribute: Attribute
            func sameKind(_ value: Attribute) -> Bool {
                Self.same(self.attribute, value)
            }
            static func same(_ lhs: Attribute, _ rhs: Attribute) -> Bool {
                switch (lhs, rhs) {
                case (.bold, .bold): return true
                case (.italic, .italic): return true
                case (.strikethrough, .strikethrough): return true
                case (.keyboard, .keyboard): return true
                default: return false
                }
            }
        }
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

    /// Well, we have Inclusive attriubtes.
    /// So, we have not only one attribute, we have a set of attributes.
    /// It is a convenient typealias to a `Set` of `Attribute`.
    typealias UserResponse = [Attribute]

    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // styles
        case bold
        case italic
        case strikethrough
        case keyboard

        static func from(attribute: Attribute) -> Self {
            switch attribute {
            case .bold: return .bold
            case .italic: return .italic
            case .strikethrough: return .strikethrough
            case .keyboard: return .keyboard
            }
        }
    }
}

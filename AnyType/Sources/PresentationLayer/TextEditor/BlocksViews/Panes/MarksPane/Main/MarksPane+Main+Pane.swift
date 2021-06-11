//
//  MarksPane+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: States and Actions
extension MarksPane.Main {
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
    /// This `Attribute` aggregates different attributes from different panes.
    enum Attribute {
        case style(Panes.StylePane.Attribute)
        case textColor(Panes.Color.Attribute)
        case backgroundColor(Panes.Color.Attribute)
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    /// Most functions have the same name and they are dispatching by a type of argument.
    /// Parameter name `style` refers to `TextView.MarkStyle`
    /// Parameter name `alignment` refers to `NSTextAlignment`
    ///
    enum Converter {
        /// All functions have name `state`.
        /// It is better to rename it to `convert` or `attribute`.
        ///
        private static func state(_ style: BlockTextView.MarkStyle) -> Attribute? {
            switch style {
            case .bold: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .italic: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .strikethrough: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)
            case .keyboard: return Panes.StylePane.Converter.state(style).flatMap(Attribute.style)

            case .underscored: return nil
            case .textColor: return Panes.Color.Converter.state(style, background: false).flatMap(Attribute.textColor)
            case .backgroundColor: return Panes.Color.Converter.state(style, background: true).flatMap(Attribute.backgroundColor)

            case .link: return nil
            }
        }
        
        private static func state(_ alignment: NSTextAlignment) -> Attribute? {
            Panes.StylePane.Converter.state(alignment).flatMap(Attribute.style)
        }

        static func state(_ style: BlockTextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }
        
        static func state(_ alignment: NSTextAlignment?) -> Attribute? {
            alignment.flatMap(state)
        }
        
        static func state(_ alignments: [NSTextAlignment]) -> [Attribute] {
            alignments.compactMap(state)
        }

        static func states(_ styles: [BlockTextView.MarkStyle]) -> [Attribute] {
            styles.compactMap(state)
        }
        
        static func states(_ styles: [BlockTextView.MarkStyle], _ alignments: [NSTextAlignment]) -> [Attribute] {
            styles.compactMap(state) + alignments.compactMap(state)
        }
    }

    // AppleBug: Switch to (NSRange, [State]) pair instead.
    // We can't just use Pairs in Publishers.
    
    /// `UserResponse` is a structure that is delivering updates from OuterWorld.
    /// So, when user want to refresh UI of this component, he needs to `select` text.
    /// Next, appropriate method will update current value of `UserResponse` in this pane.
    ///
    struct UserResponse {
        var range: NSRange = .init()
        var states: [Attribute] = []
        static var zero = Self.init()

        func isZero() -> Bool {
            return self.range == Self.zero.range && self.states.count == Self.zero.states.count
        }
    }
    
    struct RawUserResponse {
        var attributedString: NSAttributedString = .init(string: "")
        var textAlignment: NSTextAlignment = .natural
        var textColor: UIColor = .clear
        var backgroundColor: UIColor = .clear
    }

    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        case style(NSRange, Panes.StylePane.Action)
        case textColor(NSRange, Panes.Color.Action)
        case backgroundColor(NSRange, Panes.Color.Action)
    }
}

//
//  MarksPane+Panes+StylePane.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

// MARK: Style pane
extension MarksPane.Panes {
    enum StylePane {}
}

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension MarksPane.Panes.StylePane {
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
    enum Attribute {
        case fontStyle(FontStyle.Attribute)
        case alignment(Alignment.Attribute)
    }

    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    /// Most functions have the same name and they are dispatching by a type of argument.
    /// Parameter name `style` refers to `TextView.MarkStyle`
    /// Parameter name `alignment` refers to `NSTextAlignment`
    ///
    enum Converter {
        typealias Output = Attribute
        enum Input {
            case markStyle(BlockTextView.MarkStyle)
            case textAlignment(NSTextAlignment)
        }
        static func convert(_ input: Input) -> Output? {
            switch input {
            case let .markStyle(style): return FontStyle.Converter.state(style).flatMap(Attribute.fontStyle)
            case let .textAlignment(alignment): return Alignment.Converter.state(alignment).flatMap(Attribute.alignment)
            }
        }
        /// All functions have name `state`.
        /// It is better to rename it to `convert` ot `attribute`.
        ///

        private static func state(_ style: BlockTextView.MarkStyle) -> Attribute? {
            FontStyle.Converter.state(style).flatMap(Attribute.fontStyle)
        }
        
        private static func state(_ alignment: NSTextAlignment) -> Attribute? {
            Alignment.Converter.state(alignment).flatMap(Attribute.alignment)
        }
        
        static func state(_ alignment: NSTextAlignment?) -> Attribute? {
            alignment.flatMap(state)
        }
        
        static func state(_ style: BlockTextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }
        
        static func state(_ styles: [NSTextAlignment]) -> [Attribute] {
            styles.compactMap(state)
        }
        
        static func states(_ styles: [BlockTextView.MarkStyle], _ alignment: [NSTextAlignment] = []) -> [Attribute] {
            styles.compactMap(state) + alignment.compactMap(state)
        }
    }
    
    /// `UserResponse` is a structure that is delivering updates from OuterWorld.
    /// So, when user want to refresh UI of this component, he needs to `select` text.
    /// Next, appropriate method will update current value of `UserResponse` in this pane.
    ///
    enum UserResponse {
        case fontStyle(FontStyle.UserResponse)
        case alignment(Alignment.UserResponse)
    }
        
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        case fontStyle(FontStyle.Action)
        case alignment(Alignment.Action)
        
        static func from(_ attribute: Attribute) -> Self {
            switch attribute {
            case let .fontStyle(value): return .fontStyle(.from(attribute: value))
            case let .alignment(value): return .alignment(.from(attribute: value))
            }
        }
    }
}

// MARK: ListDataSource
extension MarksPane.Panes.StylePane {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
    ///
    /// Responsibilities:
    /// - Get sections count and count of items in section.
    /// - Conversion between `IndexPath` and `Attribute`.
    /// - Resources for items at `IndexPath` or for `Attribute`.
    ///
    enum ListDataSource {

        /// Since we have only two rows on our screen in current design, we are fine with constant `2`.
        /// - Returns: A count of sections (actually, rows) of cells in a pane.
        ///
        static func sectionsCount() -> Int {
            return 2
        }

        /// Well, we determine number of sections ( or rows ) in our pane.
        /// Now we have to determine count of items in a section ( in a row ).
        /// For that, we do this lookup in section index.
        ///
        /// WARNING:
        /// This method returns `valid` indices even for `section > sectionsCount` and for `section < 0`
        ///
        static func itemsCount(section: Int) -> Int {
            switch section {
            case 0: return FontStyle.ListDataSource.itemsCount(section: 0)
            case 1: return Alignment.ListDataSource.itemsCount(section: 0)
            default: return 0
            }
        }

        // MARK: Conversion: IndexPath and Attribute
        /// We should determine an indexPath for a specific case of `enum Attribute`.
        /// Here we do it.
        static func indexPath(attribute: Attribute) -> IndexPath {
            switch attribute {
            case let .fontStyle(value): return FontStyle.ListDataSource.indexPath(attribute: value)
            case let .alignment(value):
                let section = 1
                var item = Alignment.ListDataSource.indexPath(attribute: value)
                item.section = section
                return item
            }
        }

        /// We should determine a case of `enum Attribute` for specific indexPath.
        /// Here we do it.
        ///
        /// WARNING:
        /// This method uses a fact about indexPath.
        /// IndexPath doesn't align to a zero and uses `continuous numbering`.
        /// It `does not` reset `indexPath.item` to a `zero` in `new` section.
        ///
        static func attribute(at indexPath: IndexPath) -> Attribute {
            switch indexPath.section {
            case 0: return .fontStyle(FontStyle.ListDataSource.attribute(at: indexPath))
            case 1: return .alignment(Alignment.ListDataSource.attribute(at: .init(item: indexPath.item, section: 0)))
            default: return .alignment(.left) // Actually, unreachable.
            }
        }

        // MARK: Conversion: String and Attribute
        static func imageResource(attribute: Attribute) -> String {
            switch attribute {
            case let .fontStyle(value): return FontStyle.ListDataSource.imageResource(attribute: value)
            case let .alignment(value): return Alignment.ListDataSource.imageResource(attribute: value)
            }
        }
    }
}

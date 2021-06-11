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
    /// An `Attribute` from UserResponse.
    /// When user press something in related UI component, you should update state of this UI component.
    /// For us, it is a selection of UITextView.
    ///
    /// So, we receive attributes from selection of UITextView.
    ///
    /// This attribute refers to this update.
    ///
    /// That is why you have `Converter` from `TextView.MarkStyle`
    enum Attribute {
        case setColor(UIColor)
    }
    
    /// `Converter` converts `TextView.MarkStyle` -> `Attribute`.
    ///
    enum Converter {
        private static func state(_ style: BlockTextView.MarkStyle, background: Bool) -> Attribute? {
            switch style {
            case let .textColor(color): return .setColor(color ?? .defaultColor)
            case let .backgroundColor(color): return .setColor(color ?? .grayscaleWhite)
            default: return nil
            }
        }
        
        static func state(_ style: BlockTextView.MarkStyle?, background: Bool) -> Attribute? {
            style.flatMap({state($0, background: background)})
        }
        
        static func states(_ styles: [BlockTextView.MarkStyle], background: Bool) -> [Attribute] {
            styles.compactMap({state($0, background: background)})
        }
    }
    
    /// Well, we have Exclusive attriubtes.
    /// So, we have only one attribute.
    /// It is a convenient typealias to an `Attribute`.
    ///
    typealias UserResponse = Attribute
    
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // Maybe better to use Colors?
        case setColor(UIColor)
    }
}

// MARK: ListDataSource
extension MarksPane.Panes.Color {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
    enum ListDataSource {
        /// Since we have only two rows on our screen in current design, we are fine with constant `2`.
        /// - Returns: A count of sections (actually, rows) of colors in pane.
        static func sectionsCount() -> Int {
            return 2
        }
        
        /// Well, we determine number of sections ( or rows ) in our pane.
        /// Now we have to determine count of items in a section ( in a row ).
        /// For that, we do this lookup in section index.
        ///
        /// WARNING:
        /// This method returns `valid` indices even for `section > sectionsCount` and for `section < 0`
        static func itemsCount(section: Int) -> Int {
            switch section {
            case 0: return 6
            case 1: return Colors.allCases.count - self.itemsCount(section: 0)
            default: return 0
            }
        }
        
        /// We should map 1-dimensional index to our IndexPath ( 2-dimensional index ).
        /// This method return correct index path for index.
        ///
        /// WARNING:
        /// This method `does not` align `indexPath.item` to `zero`.
        /// It only add `section` value.
        ///
        /// It is fine with the following:
        ///
        /// (0, 0), (0, 1), (0, 2)
        /// (1, 3), (1, 4)
        /// (2, 5)
        static func indexPath(_ index: Int) -> IndexPath {
            for section in 0 ..< self.sectionsCount() {
                let previousCount = self.itemsCount(section: section - 1) // equal to zero for -1
                let currentCount = self.itemsCount(section: section)
                if index - previousCount < currentCount {
                    return .init(item: index, section: section)
                }
            }
            return .init(item: 0, section: 0)
        }
        
        // MARK: Conversion: IndexPath and Colors
        /// We should determine an indexPath for a specific case of `enum Colors`.
        /// Here we do it.
        static func indexPath(_ color: Colors) -> IndexPath {
            guard let index = Colors.allCases.firstIndex(of: color) else { return .init(item: 0, section: 0) }
            return self.indexPath(index)
        }
        
        /// We should determine a case of `enum Colors` for specific indexPath.
        /// Here we do it.
        ///
        /// WARNING:
        /// This method uses a fact about indexPath.
        /// IndexPath doesn't align to a zero and uses `continuous numbering`.
        /// It `does not` reset `indexPath.item` to a `zero` in `new` section.
        static func color(at indexPath: IndexPath) -> Colors {
            Colors.allCases[indexPath.item]
        }
        
        /// Conversion: UIColor and Colors
        /// Actually, we can't determine a `case` of `enum Colors` without a context: `background`.
        /// This method determines a case of `enum Colors` with `background` flag.
        ///
        /// `(UIColor, background: Bool) -> Colors`
        static func color(by color: UIColor, background: Bool) -> Colors? {
            guard let color = ColorsConverter.asMiddleware(color, background: background) else { return nil }
            return Colors(name: color)
        }
        
        // TODO: Change to String (maybe?)
        /// This method `could` use a `String` as a resource IF middleware has unique names of colors.
        /// Without it, we use a context `background` to determine `UIColor`.
        ///
        /// `(Colors, background: Bool) -> UIColor`
        static func imageResource(_ color: Colors, background: Bool) -> UIColor {
            color.color(background: background)
        }
    }
}

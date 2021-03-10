//
//  MarksPane+Panes+StylePane+AlignmentModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI
import os
import BlocksModels


private extension Logging.Categories {
    static let textViewMarksPanePanesStylePaneAlignment: Self = "MarksPane.Panes.StylePane"
}

// MARK: StylePane / Alignment
extension MarksPane.Panes.StylePane {
    enum Alignment {}
}

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension MarksPane.Panes.StylePane.Alignment {
    /// An `Attribute` from UserResponse.
    /// When user press something in related UI component, you should update state of this UI component.
    /// For us, it is a selection of UITextView.
    ///
    /// So, we receive attributes from selection of UITextView.
    ///
    /// This attribute refers to this update.
    ///
    /// That is why you have `Converter` from `Alignment`
    ///
    enum Attribute: CaseIterable {
        case left
        case center
        case right

        /// As soon as we have Exclusive `Attribute`
        /// We should be able to find attributes of the same kind.
        /// For that reason we have `allCases` with empty state.
        ///
        static var allCases: [Attribute] = [ .left, .center, .right ]
    }

    /// `Converter` converts `NSTextAlignment` -> `Attribute`.
    ///
    enum Converter {
        
        private static func descriptive(_ style: NSTextAlignment) -> Attribute? {
            let result = self.state(style)
            if result == nil {
                let logger = Logging.createLogger(category: .textViewMarksPanePanesStylePaneAlignment)
                os_log(.debug, log: logger, "We receive uncommon result. We should map it to correct attribute != nil. Style is: %@", String(describing: style))
            }
            return result
        }
        
        private static func state(_ style: NSTextAlignment) -> Attribute? {
            switch style {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            case .justified: return nil
            case .natural: return nil
            @unknown default: return nil
            }
        }

        static func state(_ style: NSTextAlignment?) -> Attribute? {
            style.flatMap(descriptive)
        }

        static func states(_ styles: [NSTextAlignment]) -> [Attribute] {
            styles.compactMap(state)
        }
    }

    /// Well, we have Inclusive attriubtes.
    /// So, we have not only one attribute, we have a set of attributes.
    /// It is a convenient typealias to a `Set` of `Attribute`.
    typealias UserResponse = Attribute

    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // styles
        case left
        case center
        case right

        static func from(attribute: Attribute) -> Self {
            switch attribute {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }

        /// Convert marks pane alignment model to block model
        /// - Returns: Alignment in block model
        func asModel() -> TopLevel.AliasesMap.Alignment {
            switch self {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
        
    }
}

// MARK: ListDataSource
extension MarksPane.Panes.StylePane.Alignment {
    /// `ListDataSource` is intended to manipulate with data at index paths.
    /// Also, it knows about the count of entries in a row at section.
    ///
    /// Responsibilities:
    /// - Get sections count and count of items in section.
    /// - Conversion between `IndexPath` and `Attribute`.
    /// - Resources for items at `IndexPath` or for `Attribute`.
    ///
    enum ListDataSource {

        /// Since we have only one row on our screen in current design, we are fine with constant `1`.
        /// - Returns: A count of sections (actually, rows) of cells in a pane.
        ///
        static func sectionsCount() -> Int {
            return 1
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
            case 0: return Attribute.allCases.count
            default: return 0
            }
        }

        // MARK: Conversion: IndexPath and Attribute
        /// We should determine an indexPath for a specific case of `enum Attribute`.
        /// Here we do it.
        static func indexPath(attribute: Attribute) -> IndexPath {
            switch attribute {
            case .left: return .init(item: 0, section: 0)
            case .center: return .init(item: 1, section: 0)
            case .right: return .init(item: 2, section: 0)
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
            Attribute.allCases[indexPath.item]
        }

        // MARK: Conversion: String and Attribute
        static func imageResource(attribute: Attribute) -> String {
            switch attribute {
            case .left: return "TextEditor/Toolbar/Alignment/Left"
            case .center: return "TextEditor/Toolbar/Alignment/Center"
            case .right: return "TextEditor/Toolbar/Alignment/Right"
            }
        }
    }
}

// MARK: CellDataBuilder
extension MarksPane.Panes.StylePane.Alignment {
    /// DataBuilder creates data for cell which will be rendered.
    /// Actually, it is not a viewModel, it is a `DataModel` or `CellData`.
    ///
    enum CellDataBuilder {
        struct Data {
            let section: Int
            let index: Int
            let imageResource: String
        }
        
        /// Creates a `Data` or `CellData`.
        /// - Parameter attribute: An Attribute for which we will create `Data` or `CellData`.
        /// - Returns: Configured `Data`or `CellData`.
        static func item(attribute: Attribute) -> Data {
            let indexPath = ListDataSource.indexPath(attribute: attribute)
            let imageResource = ListDataSource.imageResource(attribute: attribute)

            return .init(section: indexPath.section, index: indexPath.item, imageResource: imageResource)
        }
        
        /// Alias to `self.item(attribute:)`
        static func cell(attribute: Attribute) -> Data {
            self.item(attribute: attribute)
        }
    }
}

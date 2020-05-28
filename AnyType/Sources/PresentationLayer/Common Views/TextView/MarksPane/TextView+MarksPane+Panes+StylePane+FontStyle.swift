//
//  TextView+MarksPane+Panes+StylePane+FontStyle.swift
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
extension TextView.MarksPane.Panes.StylePane {
    enum FontStyle {}
}

// MARK: States and Actions
/// A set of Input(`Attribute`, `UserResponse`) and Output(`Action`) types.
/// `Attribute` refers to possible values of Input.
/// `UserResponse` refers to a set of possible values of Input.
/// `UserResponse` := (`Optional<Attribute>`, `Attribute`) | (`[Attribute]`)
/// `UserResponse` is `exclusive` ( `Optional<Attribute> | Attribute` ) or `inclusive` (`[Attribute]`).
///
extension TextView.MarksPane.Panes.StylePane.FontStyle {
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
        private static func state(_ style: TextView.MarkStyle) -> Attribute? {
            switch style {
            case let .bold(value): return .bold(value)
            case let .italic(value): return .italic(value)
            case let .strikethrough(value): return .strikethrough(value)
            case let .keyboard(value): return .keyboard(value)
            default: return nil
            }
        }

        static func state(_ style: TextView.MarkStyle?) -> Attribute? {
            style.flatMap(state)
        }

        static func states(_ styles: [TextView.MarkStyle]) -> [Attribute] {
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

// MARK: ListDataSource
extension TextView.MarksPane.Panes.StylePane.FontStyle {
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
            case .bold: return .init(item: 0, section: 0)
            case .italic: return .init(item: 1, section: 0)
            case .strikethrough: return .init(item: 2, section: 0)
            case .keyboard: return .init(item: 3, section: 0)
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
            case .bold: return "TextEditor/Toolbar/Marks/Bold"
            case .italic: return "TextEditor/Toolbar/Marks/Italic"
            case .strikethrough: return "TextEditor/Toolbar/Marks/Strikethrough"
            case .keyboard: return "TextEditor/Toolbar/Marks/Code"
            }
        }

        // MARK: Stream
        /// We have inclusive attributes (a Set of Attributes).
        /// In this case we should provide a stream ( input stream ) to update current state of specified attribute.
        static func stream(attribute: Attribute, stream: AnyPublisher<UserResponse, Never>) -> AnyPublisher<Bool, Never> {
            stream.map{ value -> Attribute? in
                return value.first(where: Attribute.Kind(attribute: attribute).sameKind)
            }.safelyUnwrapOptionals().map(\.boolValue).eraseToAnyPublisher()
        }
    }
}

// MARK: ViewModelBuilder
extension TextView.MarksPane.Panes.StylePane.FontStyle {
    /// DataBuilder creates data for cell which will be rendered.
    /// Actually, it is not a viewModel, it is a `DataModel` or `CellData`.
    ///
    enum CellDataBuilder {
        struct Data {
            let section: Int
            let index: Int
            let imageResource: String
            var stateStream: AnyPublisher<Bool, Never> = .empty()
            
            func configured(stateStream: AnyPublisher<Bool, Never>) -> Self {
                return .init(section: self.section, index: self.index, imageResource: self.imageResource, stateStream: stateStream)
            }
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
        /// - Parameters:
        ///   - attribute: An Attribute for which we will create `Data` or `CellData`.
        ///   - stream: Additional parameter stream. This stream refers to input values for concrete cell.
        /// - Returns: Configured `Data` or `CellData`.
        static func cell(attribute: Attribute, stream: AnyPublisher<UserResponse, Never>) -> Data {
            self.item(attribute: attribute).configured(stateStream: ListDataSource.stream(attribute: attribute, stream: stream))
        }
    }
}

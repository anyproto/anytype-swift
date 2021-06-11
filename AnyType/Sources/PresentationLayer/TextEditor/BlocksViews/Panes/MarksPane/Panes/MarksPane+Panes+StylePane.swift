import Foundation
import UIKit
import Combine
import SwiftUI
import BlocksModels

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
        case alignment(BlockInformationAlignment)
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
            case let .markStyle(style):
                return FontStyle.Converter.state(style).flatMap(Attribute.fontStyle)
            case let .textAlignment(alignment):
                return BlockInformationAlignmentConverter.convert(alignment).flatMap(Attribute.alignment)
            }
        }
        /// All functions have name `state`.
        /// It is better to rename it to `convert` ot `attribute`.
        ///

        private static func state(_ style: BlockTextView.MarkStyle) -> Attribute? {
            FontStyle.Converter.state(style).flatMap(Attribute.fontStyle)
        }
        
        private static func state(_ alignment: NSTextAlignment) -> Attribute? {
            BlockInformationAlignmentConverter.convert(alignment).flatMap(Attribute.alignment)
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
        case alignment(BlockInformationAlignment)
    }
        
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// This pane is set of panes, so, whenever user pressed a cell in child pane, update will deliver to OuterWorld.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        case fontStyle(FontStyle.Action)
        case alignment(BlockInformationAlignment)
        
        static func from(_ attribute: Attribute) -> Self {
            switch attribute {
            case let .fontStyle(value): return .fontStyle(.from(attribute: value))
            case let .alignment(value): return .alignment(value)
            }
        }
    }
}

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
    
    /// `Action` is an action from User, when he pressed current cell in this pane.
    /// It refers to outgoing ( or `to OuterWorld` ) publisher.
    ///
    enum Action {
        // Maybe better to use Colors?
        case setColor(UIColor)
    }
}

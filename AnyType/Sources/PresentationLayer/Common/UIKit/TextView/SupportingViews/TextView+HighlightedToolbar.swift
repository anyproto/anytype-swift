//
//  TextView+HighlightedToolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension BlockTextView {
    enum HighlightedToolbar {}
}

// MARK: UnderlyingAction
extension BlockTextView.HighlightedToolbar {
    enum UnderlyingAction {
        enum MarksType {
            case bold(Bool)
            case italic(Bool)
            case keyboard(Bool)
            case strikethrough(Bool)
            case underscored(Bool)
            case link(URL?) // should retrieve in custom place
            case textColor(UIColor?) // should retrieve in custom place
            case backgroundColor(UIColor?) // should retrieve in custom place
            static func convert(_ type: BlockTextView.MarkStyle) -> Self {
                switch type {
                case let .bold(value): return .bold(value)
                case let .italic(value): return .italic(value)
                case let .keyboard(value): return .keyboard(value)
                case let .strikethrough(value): return .strikethrough(value)
                case let .underscored(value): return .underscored(value)
                case let .textColor(value): return .textColor(value)
                case let .backgroundColor(value): return .backgroundColor(value)
                case let .link(value): return .link(value)
                }
            }
        }
        // TODO: Think about api usage.
        // Should we send single value or an array?
        case changeMark(NSRange, MarksType)
    }
}

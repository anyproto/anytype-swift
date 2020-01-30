//
//  TextView+HighlightedToolbar.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

extension TextView {
    enum HighlightedToolbar {}
}

// MARK: UnderlyingAction
extension TextView.HighlightedToolbar {
    enum UnderlyingAction {
        enum MarksType {
            case bold(Bool)
            case italic(Bool)
            case strikethrough(Bool)
            case code(Bool)
            case link(URL?) // should retrieve in custom place
            case textColor(UIColor?) // should retrieve in custom place
            case backgroundColor(UIColor?) // should retrieve in custom place
            static func convert(_ type: State) -> Self {
                switch type {
                case let .bold(value): return .bold(value)
                case let .italic(value): return .italic(value)
                case let .strikethrough(value): return .strikethrough(value)
                case let .code(value): return .code(value)
                case .link(_): return .link(nil) // not used, actually. Use appropriate convertor
                }
            }
            static func convert(_ link: URL?) -> Self {
                return .link(link)
            }
            static func convert(_ pair: (UIColor?, UIColor?), background: Bool) -> Self {
                if background {
                    return .backgroundColor(pair.1)
                }
                else {
                    return .textColor(pair.0)
                }
            }
            static func convert(textColor: UIColor?) -> Self {
                .textColor(textColor)
            }
            static func convert(backgroundColor: UIColor?) -> Self {
                .backgroundColor(backgroundColor)
            }
        }
        case changeMark(NSRange, MarksType)
    }
}

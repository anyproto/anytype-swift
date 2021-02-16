//
//  BlocksModelsModule+Parser+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    enum Other {}
}

extension Namespace.Other {
    enum Divider {}
}

extension Namespace.Other.Divider {
    enum Style {}
}

extension Namespace.Other.Divider.Style {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Divider.Style
        typealias MiddlewareModel = Anytype_Model_Block.Content.Div.Style
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .line: return .line
            case .dots: return .dots
            }
        }
    }
}

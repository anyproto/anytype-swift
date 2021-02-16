//
//  BlocksModelsModule+Parser+Layout.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 05.11.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    enum Layout {}
}

extension Namespace.Layout {
    enum Style {}
}

extension Namespace.Layout.Style {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Layout.Style
        typealias MiddlewareModel = Anytype_Model_Block.Content.Layout.Style
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .row: return .row
            case .column: return .column
            case .div: return .div
            case .header: return .header
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .row: return .row
            case .column: return .column
            case .div: return .div
            case .header: return .header
            }
        }
    }
}

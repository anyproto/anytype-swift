//
//  BlocksModelsModule+Parser+Link.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    enum Link {}
}

extension Namespace.Link {
    enum Style {}
}

extension Namespace.Link.Style {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Link.Style
        typealias MiddlewareModel = Anytype_Model_Block.Content.Link.Style
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .page: return .page
            case .dataview: return .dataview
            case .dashboard: return nil
            case .archive: return nil
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .page: return .page
            case .dataview: return .dataview
            }
        }
    }
}

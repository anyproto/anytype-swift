//
//  BlocksModelsModule+Parser+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    enum Bookmark {}
}

extension Namespace.Bookmark {
    enum TypeEnum {}
}

extension Namespace.Bookmark.TypeEnum {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Bookmark.TypeEnum
        typealias MiddlewareModel = Anytype_Model_LinkPreview.TypeEnum
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .unknown: return .unknown
            case .page: return .page
            case .image: return .image
            case .text: return .text
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .unknown: return .unknown
            case .page: return .page
            case .image: return .image
            case .text: return .text
            }
        }
    }
}

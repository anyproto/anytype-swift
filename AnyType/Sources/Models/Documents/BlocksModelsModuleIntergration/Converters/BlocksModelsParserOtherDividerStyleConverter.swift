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

final class BlocksModelsParserOtherDividerStyleConverter {
    typealias Model = BlockContent.Divider.Style
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

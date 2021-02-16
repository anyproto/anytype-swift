//
//  BlocksModelsModule+Parser+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    typealias Text = MiddlewareModelsModule.Parsers.Text
}

// MARK: - Text / Style
extension Namespace.Text {
    enum ContentType {}
}

extension Namespace.Text.ContentType {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.BlockContent.Text.ContentType
        typealias MiddlewareModel = Anytype_Model_Block.Content.Text.Style
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .paragraph: return .text
            case .header1: return .header
            case .header2: return .header2
            case .header3: return .header3
            case .header4: return .header4
            case .quote: return .quote
            case .code: return nil
            case .title: return nil
            case .checkbox: return .checkbox
            case .marked: return .bulleted
            case .numbered: return .numbered
            case .toggle: return .toggle
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .text: return .paragraph
            case .header: return .header1
            case .header2: return .header2
            case .header3: return .header3
            case .header4: return .header4
            case .quote: return .quote
            case .checkbox: return .checkbox
            case .bulleted: return .marked
            case .numbered: return .numbered
            case .toggle: return .toggle
            default: return nil
            }
        }
    }
}


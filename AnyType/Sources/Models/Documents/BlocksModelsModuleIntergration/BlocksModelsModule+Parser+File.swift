//
//  BlocksModelsModule+Parser+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule.Parser

extension Namespace {
    enum File {}
}


// MARK: - State
extension Namespace.File {
    enum State {}
}

// MARK: - State / Converter
extension Namespace.File.State {
    enum Converter {
        typealias Model = TopLevel.BlockContent.File.State
        typealias MiddlewareModel = Anytype_Model_Block.Content.File.State
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .empty: return .empty
            case .uploading: return .uploading
            case .done: return .done
            case .error: return .error
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .empty: return .empty
            case .uploading: return .uploading
            case .done: return .done
            case .error: return .error
            }
        }
    }
}

// MARK: - Type
extension Namespace.File {
    enum ContentType {}
}

// MARK: - Type / Converter
extension Namespace.File.ContentType {
    enum Converter {
        typealias Model = TopLevel.BlockContent.File.ContentType
        typealias MiddlewareModel = Anytype_Model_Block.Content.File.TypeEnum
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .none: return .some(.none)
            case .file: return .file
            case .image: return .image
            case .video: return .video
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .none: return .some(.none)
            case .file: return .file
            case .image: return .image
            case .video: return .video
            }
        }
    }
}

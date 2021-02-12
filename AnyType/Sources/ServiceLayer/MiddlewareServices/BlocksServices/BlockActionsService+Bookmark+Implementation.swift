//
//  BlockActionsService+Bookmark+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import Combine

fileprivate typealias Namespace = ServiceLayerModule.Bookmark
fileprivate typealias FileNamespace = Namespace.BlockActionsService

/// Concrete service that adopts BookmarkBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - BookmarkActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceBookmarkProtocol {
        
        var fetchBookmark: FetchBookmark = .init()
    }
}

private extension FileNamespace {
    enum PossibleError: Error {
        case createAndFetchBookmarkActionPositionConversionHasFailed
    }
}

// MARK: - BookmarkActionsService / Actions
extension FileNamespace {
    /// Structure that adopts `FetchBookmark` action protocol
    struct FetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: BlockId, blockID: BlockId, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.Fetch.Service.invoke(contextID: contextID, blockID: blockID, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    /// Structure that adopts `CreateAndFetchBookmark` action protocol
    struct CreateAndFetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: BlockId, targetID: BlockId, position: Position, url: String) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            guard let position = BlocksModelsModule.Parser.Common.Position.Converter.asMiddleware(position) else {
                return Fail.init(error: PossibleError.createAndFetchBookmarkActionPositionConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, targetID: targetID, position: position, url: url)
        }
        private func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.CreateAndFetch.Service.invoke(contextID: contextID, targetID: targetID, position: position, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

//
//  BlockActionsService+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

fileprivate typealias Namespace = ServiceLayerModule.Bookmark

// MARK: - Actions Protocols
/// Protocol for fetch bookmark.
protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark {
    associatedtype Success
    func action(contextID: String, blockID: String, url: String) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
    associatedtype Success
    func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Bookmark actions services.
protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocol {
    associatedtype FetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark
    var fetchBookmark: FetchBookmark {get}
}

/// Concrete service that adopts BookmarkBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - BookmarkActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceBookmarkProtocol {
        
        var fetchBookmark: FetchBookmark = .init()
    }
}

// MARK: - BookmarkActionsService / Actions
extension Namespace.BlockActionsService {
    /// Structure that adopts `FetchBookmark` action protocol
    struct FetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: String, blockID: String, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.Fetch.Service.invoke(contextID: contextID, blockID: blockID, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    /// Structure that adopts `CreateAndFetchBookmark` action protocol
    struct CreateAndFetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.CreateAndFetch.Service.invoke(contextID: contextID, targetID: targetID, position: position, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

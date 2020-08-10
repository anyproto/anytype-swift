//
//  BookmarkBlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

// MARK: - Actions Protocols
/// Protocol for fetch bookmark.
protocol NewModel_BookmarkBlockActionsServiceProtocolFetchBookmark {
    associatedtype Success
    func action(contextID: String, blockID: String, url: String) -> AnyPublisher<Success, Error>
}

protocol NewModel_BookmarkBlockActionsServiceProtocolCreateAndFetchBookmark {
    associatedtype Success
    func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Bookmark actions services.
protocol NewModel_BookmarkBlockActionsServiceProtocol {
    associatedtype FetchBookmark: NewModel_BookmarkBlockActionsServiceProtocolFetchBookmark
    var fetchBookmark: FetchBookmark {get}
}

/// Concrete service that adopts BookmarkBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - BookmarkActionsService

fileprivate typealias Namespace = ServiceLayerModule

extension Namespace {
    class BookmarkBlockActionsService: NewModel_BookmarkBlockActionsServiceProtocol {
        
        var fetchBookmark: FetchBookmark = .init()
    }
}

// MARK: - BookmarkActionsService / FetchBookmark
extension Namespace.BookmarkBlockActionsService {
    typealias Success = ServiceLayerModule.Success
    /// Structure that adopts `FetchBookmark` action protocol
    struct FetchBookmark: NewModel_BookmarkBlockActionsServiceProtocolFetchBookmark {
        func action(contextID: String, blockID: String, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.Fetch.Service.invoke(contextID: contextID, blockID: blockID, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
}

// MARK: - BookmarkActionsService / CreateAndFetchBookmark
extension Namespace.BookmarkBlockActionsService {
    /// Structure that adopts `CreateAndFetchBookmark` action protocol
    struct CreateAndFetchBookmark: NewModel_BookmarkBlockActionsServiceProtocolCreateAndFetchBookmark {
        func action(contextID: String, targetID: String, position: Anytype_Model_Block.Position, url: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Bookmark.CreateAndFetch.Service.invoke(contextID: contextID, targetID: targetID, position: position, url: url).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

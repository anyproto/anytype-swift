//
//  BlockActionsService+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for fetch bookmark.
protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, url: String) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocolCreateAndFetchBookmark {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = BlocksModelsModule.Parser.Common.Position.Position
    func action(contextID: BlockId, targetID: BlockId, position: Position, url: String) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Bookmark actions services.
protocol ServiceLayerModule_BlockActionsServiceBookmarkProtocol {
    associatedtype FetchBookmark: ServiceLayerModule_BlockActionsServiceBookmarkProtocolFetchBookmark
    var fetchBookmark: FetchBookmark {get}
}

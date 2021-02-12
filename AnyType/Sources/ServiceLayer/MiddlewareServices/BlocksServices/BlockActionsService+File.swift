//
//  BlockActionsService+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.11.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for upload data at filePath.
protocol ServiceLayerModule_BlockActionsServiceFileProtocolUploadDataAtFilePath {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, filePath: String) -> AnyPublisher<Success, Error>
}

/// Protocol for upload data at filePath.
protocol ServiceLayerModule_BlockActionsServiceFileProtocolUploadFile {
    associatedtype Success
    typealias ContentType = TopLevel.AliasesMap.BlockContent.File.ContentType
    func action(url: String, localPath: String, type: ContentType, disableEncryption: Bool) -> AnyPublisher<Success, Error>
}

/// Protocol for fetch image as blob.
protocol ServiceLayerModule_BlockActionsServiceFileProtocolFetchImageAsBlob {
    associatedtype Success
    func action(hash: String, wantWidth: Int32) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for File blocks actions services.
protocol ServiceLayerModule_BlockActionsServiceFileProtocol {
    associatedtype UploadDataAtFilePath: ServiceLayerModule_BlockActionsServiceFileProtocolUploadDataAtFilePath
    associatedtype UploadFile: ServiceLayerModule_BlockActionsServiceFileProtocolUploadFile
    associatedtype FetchImageAsBlob: ServiceLayerModule_BlockActionsServiceFileProtocolFetchImageAsBlob

    var uploadDataAtFilePath: UploadDataAtFilePath {get}
    var uploadFile: UploadFile {get}
    var fetchImageAsBlob: FetchImageAsBlob {get}
}

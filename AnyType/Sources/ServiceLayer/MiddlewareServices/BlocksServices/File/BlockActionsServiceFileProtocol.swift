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
protocol BlockActionsServiceFileProtocolUploadDataAtFilePath {
    associatedtype Success
    func action(contextID: BlockId, blockID: BlockId, filePath: String) -> AnyPublisher<Success, Error>
}

/// Protocol for upload data at filePath.
protocol BlockActionsServiceFileProtocolUploadFile {
    associatedtype Success
    typealias ContentType = TopLevel.BlockContent.File.ContentType
    func action(url: String, localPath: String, type: ContentType, disableEncryption: Bool) -> AnyPublisher<Success, Error>
}

/// Protocol for fetch image as blob.
protocol BlockActionsServiceFileProtocolFetchImageAsBlob {
    associatedtype Success
    func action(hash: String, wantWidth: Int32) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for File blocks actions services.
protocol BlockActionsServiceFileProtocol {
    associatedtype UploadDataAtFilePath: BlockActionsServiceFileProtocolUploadDataAtFilePath
    associatedtype UploadFile: BlockActionsServiceFileProtocolUploadFile
    associatedtype FetchImageAsBlob: BlockActionsServiceFileProtocolFetchImageAsBlob

    var uploadDataAtFilePath: UploadDataAtFilePath {get}
    var uploadFile: UploadFile {get}
    var fetchImageAsBlob: FetchImageAsBlob {get}
}

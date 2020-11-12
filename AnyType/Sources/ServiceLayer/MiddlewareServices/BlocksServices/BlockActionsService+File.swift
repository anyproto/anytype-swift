//
//  BlockActionsService+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.11.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

fileprivate typealias Namespace = ServiceLayerModule.File

// MARK: - Actions Protocols
/// Protocol for upload data at filePath.
protocol ServiceLayerModule_BlockActionsServiceFileProtocolUploadDataAtFilePath {
    associatedtype Success
    func action(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Success, Error>
}

/// Protocol for upload data at filePath.
protocol ServiceLayerModule_BlockActionsServiceFileProtocolUploadFile {
    associatedtype Success
    func action(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<Success, Error>
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

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - File.BlockActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceFileProtocol {
        
        var uploadDataAtFilePath: UploadDataAtFilePath = .init()
        var uploadFile: UploadFile = .init()
        var fetchImageAsBlob: FetchImageAsBlob = .init()
    }
}

// MARK: - File.BlockActionsService / Actions
extension Namespace.BlockActionsService {
    /// Structure that adopts `UploadDataAtFilePath` action protocol.
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    struct UploadDataAtFilePath: ServiceLayerModule_BlockActionsServiceFileProtocolUploadDataAtFilePath {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Success, Error>  {
            Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "")
                .map(\.event).map(Success.init).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct UploadFile: ServiceLayerModule_BlockActionsServiceFileProtocolUploadFile {
        struct Success {
            var hash: String
            init(hash: String) {
                self.hash = hash
            }
            fileprivate init(response: Anytype_Rpc.UploadFile.Response) {
                self.init(hash: response.hash)
            }
        }
        
        func action(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.UploadFile.Service.invoke(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    struct FetchImageAsBlob: ServiceLayerModule_BlockActionsServiceFileProtocolFetchImageAsBlob {
        struct Success {
            var blob: Data
            init(blob: Data) {
                self.blob = blob
            }
            init(response: Anytype_Rpc.Ipfs.Image.Get.Blob.Response) {
                self.init(blob: response.blob)
            }
        }
        
        func action(hash: String, wantWidth: Int32) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Ipfs.Image.Get.Blob.Service.invoke(hash: hash, wantWidth: wantWidth, queue: .global()).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

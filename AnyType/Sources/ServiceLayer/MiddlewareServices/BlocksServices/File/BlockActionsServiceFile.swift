//
//  BlockActionsService+File+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import ProtobufMessages

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.

class BlockActionsServiceFile: BlockActionsServiceFileProtocol {
    
    var uploadDataAtFilePath: UploadDataAtFilePath = .init()
    var uploadFile: UploadFile = .init()
    var fetchImageAsBlob: FetchImageAsBlob = .init()
}

private extension BlockActionsServiceFile {
    enum PossibleError: Error {
        case uploadFileActionContentTypeConversionHasFailed
    }
}

// MARK: - File.BlockActionsService / Actions
extension BlockActionsServiceFile {
    /// Structure that adopts `UploadDataAtFilePath` action protocol.
    /// NOTE: `Upload` action will return message with event `blockSetFile.state == .uploading`.
    struct UploadDataAtFilePath: BlockActionsServiceFileProtocolUploadDataAtFilePath {
        typealias Success = ServiceSuccess
        func action(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Success, Error>  {
            Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "")
                .map(\.event).map(Success.init).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct UploadFile: BlockActionsServiceFileProtocolUploadFile {
        struct Success {
            var hash: String
            init(hash: String) {
                self.hash = hash
            }
            fileprivate init(response: Anytype_Rpc.UploadFile.Response) {
                self.init(hash: response.hash)
            }
        }
        
        func action(url: String, localPath: String, type: ContentType, disableEncryption: Bool) -> AnyPublisher<Success, Error> {
            guard let contentType = BlocksModelsParserFileContentTypeConverter.asMiddleware(type) else {
                return Fail.init(error: PossibleError.uploadFileActionContentTypeConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(url: url, localPath: localPath, type: contentType, disableEncryption: disableEncryption)
        }
        
        private func action(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.UploadFile.Service.invoke(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    struct FetchImageAsBlob: BlockActionsServiceFileProtocolFetchImageAsBlob {
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

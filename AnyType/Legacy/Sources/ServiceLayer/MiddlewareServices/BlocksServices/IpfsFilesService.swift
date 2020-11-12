//
//  IpfsFilesService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import Lib

/// request/response model
fileprivate struct IpfsFilesModel {
    enum Image {
        enum Download {}
    }
    enum File {
        enum Download {}
    }
}


fileprivate extension IpfsFilesModel.Image.Download {
    enum DownloadError: Error {
        case downLoadImageError
    }

    struct Request {
        let hash: String
        let wantWidth: Int32
    }

    struct Response {
        let data: Data
        let error: DownloadError
    }
}


extension IpfsFilesModel.Image.Download.DownloadError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .downLoadImageError:
            return "Error downloading image"
        }
    }
}


/// Ipfs file service
class IpfsFilesService {
    
    var uploadDataAtFilePath: UploadDataAtFilePath = .init()
    var uploadFile: UploadFile = .init()
    var fetchImageAsBlob: FetchImageAsBlob = .init()
    
    struct UploadDataAtFilePath {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Success, Error>  {
            Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "")
                .map(\.event).map(Success.init).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct UploadFile {
        struct Success {
            var hash: String
            init(hash: String) {
                self.hash = hash
            }
        }
        
        func action(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.UploadFile.Service.invoke(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    struct FetchImageAsBlob {
        struct Success {
            var blob: Data
            init(blob: Data) {
                self.blob = blob
            }
        }
        
        func action(hash: String, wantWidth: Int32) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Ipfs.Image.Get.Blob.Service.invoke(hash: hash, wantWidth: wantWidth, queue: .global()).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

fileprivate extension IpfsFilesService.UploadFile.Success {
    init(response: Anytype_Rpc.UploadFile.Response) {
        self.init(hash: response.hash)
    }
}

fileprivate extension IpfsFilesService.FetchImageAsBlob.Success {
    init(response: Anytype_Rpc.Ipfs.Image.Get.Blob.Response) {
        self.init(blob: response.blob)
    }
}

// Deprecated.
// TODO: Remove it later.
fileprivate extension IpfsFilesService {
    private func fetchImage(requestModel: IpfsFilesModel.Image.Download.Request) -> Future<Data, IpfsFilesModel.Image.Download.DownloadError> {

        Future<Data, IpfsFilesModel.Image.Download.DownloadError>  { [weak self] promise in
            self?.fetchImage(requestModel: requestModel) { result in
                promise(result)
            }
        }
    }

    private func fetchImage(requestModel: IpfsFilesModel.Image.Download.Request, _ completion: @escaping (Result<Data, IpfsFilesModel.Image.Download.DownloadError>) -> Void) {
        var imageRequest = Anytype_Rpc.Ipfs.Image.Get.Blob.Request()
        imageRequest.hash = requestModel.hash
        imageRequest.wantWidth = requestModel.wantWidth

        let requestData = try? imageRequest.serializedData()

        DispatchQueue.global().async {
            if let requestData = requestData {
                guard
                    let data = Lib.ServiceImageGetBlob(requestData),
                    let response = try? Anytype_Rpc.Ipfs.Image.Get.Blob.Response(serializedData: data),
                    response.error.code == .null else {
                        completion(.failure(.downLoadImageError))
                        return
                }
                completion(.success(response.blob))
            }
        }
    }
    
    // Need to make file uploader/downloder class & Listen for callback
    private func upload(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Void, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "").successToVoid().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}

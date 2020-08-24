//
//  IpfsFilesService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Lib
import Combine

/// request/response model
struct IpfsFilesModel {
    enum Image {
        enum Download {}
    }
    enum File {
        enum Download {}
    }
}


extension IpfsFilesModel.Image.Download {
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

    var uploadFile: UploadFile = .init()
    
    func fetchImage(requestModel: IpfsFilesModel.Image.Download.Request) -> Future<Data, IpfsFilesModel.Image.Download.DownloadError> {

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
                    let data = Lib.LibImageGetBlob(requestData),
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
    func upload(contextID: String, blockID: String, filePath: String) -> AnyPublisher<Void, Error>  {
        Anytype_Rpc.Block.Upload.Service.invoke(contextID: contextID, blockID: blockID, filePath: filePath, url: "").successToVoid().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    struct UploadFile {
        struct Success {
            var hash: String
            init(hash: String) {
                self.hash = hash
            }
            init(response: Anytype_Rpc.UploadFile.Response) {
                self.hash = response.hash
            }
        }
        
        func action(url: String, localPath: String, type: Anytype_Model_Block.Content.File.TypeEnum, disableEncryption: Bool) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.UploadFile.Service.invoke(url: url, localPath: localPath, type: type, disableEncryption: disableEncryption).map(Success.init).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

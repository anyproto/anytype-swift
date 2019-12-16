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

class IpfsFilesService {
    
    func fetchImage(requestModel: IpfsFilesModel.Image.Download.Request) -> Future<Data, IpfsFilesModel.Image.Download.DownloadError> {
        
        Future<Data, IpfsFilesModel.Image.Download.DownloadError>  { [weak self] promise in
            self?.fetchImage(requestModel: requestModel) { result in
                promise(result)
            }
        }
    }
    
    private func fetchImage(requestModel: IpfsFilesModel.Image.Download.Request, _ completion: @escaping (Result<Data, IpfsFilesModel.Image.Download.DownloadError>) -> Void) {
        var imageRequest = Anytype_Rpc.Ipfs.Image.Get.Blob.Request()
        imageRequest.id = requestModel.id
        imageRequest.size = requestModel.size
        
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
}

//
//  IpfsFilesModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation


struct IpfsFilesModel {
    struct Image {
        struct Download {}
    }
    struct File {
        struct Download {}
    }
}


extension IpfsFilesModel.Image.Download {
    enum DownloadError: Error {
        case downLoadImageError
    }
    
    struct Request {
        let id: String
        let size: Anytype_Model_Image.Size
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

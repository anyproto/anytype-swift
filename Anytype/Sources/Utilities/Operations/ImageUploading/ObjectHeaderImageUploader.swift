//
//  ObjectHeaderImageUploader.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class ObjectHeaderImageUploader: FileUploaderProtocol {
    
    private let fileService = BlockActionsServiceFile()
    
    let contentType: MediaPickerContentType = .images
    
    func uploadFileAt(localPath: String) -> Hash? {
        fileService.syncUploadImageAt(localPath: localPath)
    }
    
}

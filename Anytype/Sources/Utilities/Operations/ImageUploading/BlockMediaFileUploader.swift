//
//  BlockMediaFileUploader.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class BlockMediaFileUploader: FileUploaderProtocol {
    
    let contentType: MediaPickerContentType
    
    private let fileService = BlockActionsServiceFile()
    
    private let objectId: String
    private let blockId: String
    
    init(objectId: String, blockId: String, contentType: MediaPickerContentType) {
        self.objectId = objectId
        self.blockId = blockId
        self.contentType = contentType
    }
    
    func uploadFileAt(localPath: String) -> Hash? {
        fileService.syncUploadDataAt(
            filePath: localPath,
            contextID: objectId,
            blockID: blockId
        )
        
        return nil
    }

}

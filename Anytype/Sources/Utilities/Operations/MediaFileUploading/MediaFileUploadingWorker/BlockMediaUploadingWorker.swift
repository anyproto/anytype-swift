//
//  BlockMediaUploadingWorker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class BlockMediaUploadingWorker {

    let contentType: MediaPickerContentType
    
    private let fileService = FileActionsService()
    
    private let objectId: String
    private let blockId: String
    
    init(objectId: String, blockId: String, contentType: MediaPickerContentType) {
        self.objectId = objectId
        self.blockId = blockId
        self.contentType = contentType
    }
    
}

extension BlockMediaUploadingWorker: MediaFileUploadingWorkerProtocol {
    
    func cancel() {
        // do nothing
    }
    
    func prepare() {
        // do nothing
    }
    
    func upload(_ localPath: String) {
        fileService.syncUploadDataAt(
            filePath: localPath,
            contextID: objectId,
            blockID: blockId
        )
    }
    
    func finish() {
        // do nothing
    }
    
}

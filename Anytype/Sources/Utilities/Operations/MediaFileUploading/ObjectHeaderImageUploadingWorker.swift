//
//  ObjectHeaderImageUploadingWorker.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

final class ObjectHeaderImageUploadingWorker {
    
    private var uploadedImageHash: Hash?
    
    private let fileService = BlockActionsServiceFile()
    private let detailsService: ObjectDetailsService
    private let usecase: ObjectHeaderImageUsecase
    
    init(detailsService: ObjectDetailsService, usecase: ObjectHeaderImageUsecase) {
        self.detailsService = detailsService
        self.usecase = usecase
    }
    
}

extension ObjectHeaderImageUploadingWorker: FileUploadingWorkerProtocol {
    
    var contentType: MediaPickerContentType {
        .images
    }

    func cancel() {
        // TODO: - Implement
    }
    
    func prepare() {
        NotificationCenter.default.post(
            name: usecase.notificationName,
            object: ""
        )
    }
    
    func upload(_ localPath: String) {
        NotificationCenter.default.post(
            name: usecase.notificationName,
            object: localPath
        )
        uploadedImageHash = fileService.syncUploadImageAt(localPath: localPath)
    }
    
    func finish() {
        guard let hash = uploadedImageHash else { return }
        
        detailsService.update(
            details: usecase.updatedDetails(with: hash)
        )
    }
    
}

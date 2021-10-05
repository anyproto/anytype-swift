//
//  CoverImageUploadingStateHandler.swift
//  Anytype
//
//  Created by Konstantin Mordan on 28.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

final class CoverImageUploadingStateHandler: FileUploadingStateHandlerProtocol {
    
    // MARK: - Private variables
    
    private let detailsService: ObjectDetailsService
    
    // MARK: - Initializers
    
    init(detailsService: ObjectDetailsService) {
        self.detailsService = detailsService
    }
    
    // MARK: - FileUploadingStateHandlerProtocol
    
    func handleImageUploadingState(_ state: FileUploadingState) {
        switch state {
        case .preparing:
            NotificationCenter.default.post(
                name: .documentCoverImageUploadingEvent,
                object: ""
            )
        case .uploading(let localPath):
            NotificationCenter.default.post(
                name: .documentCoverImageUploadingEvent,
                object: localPath
            )
        case .finished(let hash):
            guard let hash = hash else {
                return
            }
            
            detailsService.update(
                details: [
                    .coverType: DetailsEntry(value: CoverType.uploadedImage),
                    .coverId: DetailsEntry(value: hash.value)
                ]
            )
        case .cancelled:
            break
        }
    }
    
}

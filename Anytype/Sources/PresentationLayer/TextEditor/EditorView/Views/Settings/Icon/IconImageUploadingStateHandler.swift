//
//  IconImageUploadingStateHandler.swift
//  Anytype
//
//  Created by Konstantin Mordan on 28.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

final class IconImageUploadingStateHandler: FileUploadingStateHandlerProtocol {
    
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
                name: .documentIconImageUploadingEvent,
                object: ""
            )
        case .uploading(let localPath):
            NotificationCenter.default.post(
                name: .documentIconImageUploadingEvent,
                object: localPath
            )
        case .finished(let hash):
            guard let hash = hash else {
                return
            }
            
            detailsService.update(
                details: [
                    .iconEmoji: DetailsEntry(value: ""),
                    .iconImage: DetailsEntry(value: hash.value)
                ]
            )
        case .cancelled:
            break
        }
    }
    
}


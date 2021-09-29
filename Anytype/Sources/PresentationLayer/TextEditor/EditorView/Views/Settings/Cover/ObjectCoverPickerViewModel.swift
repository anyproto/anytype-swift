//
//  ObjectCoverPickerViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 15.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import Combine

final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    // MARK: - Private variables
    
    private let imageUploadingDemon = ImageUploadingDemon.shared
    private let fileService: BlockActionsServiceFile
    private let detailsService: ObjectDetailsService
    
    private var uploadImageSubscription: AnyCancellable?
    
    // MARK: - Initializer
    
    init(fileService: BlockActionsServiceFile, detailsService: ObjectDetailsService) {
        self.fileService = fileService
        self.detailsService = detailsService
    }
    
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        detailsService.update(
            details: [
                .coverType: DetailsEntry(value: CoverType.color),
                .coverId: DetailsEntry(value: colorName)
            ]
        )
    }
    
    func setGradient(_ gradientName: String) {
        detailsService.update(
            details: [
                .coverType: DetailsEntry(value: CoverType.gradient),
                .coverId: DetailsEntry(value: gradientName)
            ]
        )
    }
    
    
    func uploadImage(from itemProvider: NSItemProvider) {
        // yes, we capture detailsService in order to perform update details if user leave current screen
        imageUploadingDemon.uploadImageFrom(item: itemProvider) { [detailsService] uploadedImageHash in
            detailsService.update(
                details: [
                    .coverType: DetailsEntry(value: CoverType.uploadedImage),
                    .coverId: DetailsEntry(value: uploadedImageHash)
                ]
            )
        }
    }
    
    func removeCover() {
        detailsService.update(
            details: [
                .coverType: DetailsEntry(value: CoverType.none),
                .coverId: DetailsEntry(value: "")
            ]
        )
    }
    
}

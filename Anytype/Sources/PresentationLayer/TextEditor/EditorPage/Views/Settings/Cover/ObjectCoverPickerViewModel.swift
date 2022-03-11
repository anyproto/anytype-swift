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
import Amplitude

final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    // MARK: - Private variables
    
    private let objectId: BlockId
    private let imageUploadingDemon = MediaFileUploadingDemon.shared
    private let fileService: BlockActionsServiceFile
    private let detailsService: DetailsService
        
    // MARK: - Initializer
    
    init(objectId: BlockId, fileService: BlockActionsServiceFile, detailsService: DetailsService) {
        self.objectId = objectId
        self.fileService = fileService
        self.detailsService = detailsService
    }
    
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.color), .coverId(colorName)]
        )
    }
    
    func setGradient(_ gradientName: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.gradient), .coverId(gradientName)]
        )
    }
    
    
    func uploadImage(from itemProvider: NSItemProvider) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: ObjectHeaderImageUploadingWorker(
                objectId: objectId,
                detailsService: detailsService,
                usecase: .cover
            )
        )
        imageUploadingDemon.addOperation(operation)
    }
    
    func removeCover() {
        Amplitude.instance().logEvent(AmplitudeEventsName.removeCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.none), .coverId("")]
        )
    }
    
}

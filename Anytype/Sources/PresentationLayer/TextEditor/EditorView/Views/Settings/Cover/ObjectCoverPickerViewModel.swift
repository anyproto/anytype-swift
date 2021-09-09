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
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            mediaPickerContentType.supportedTypeIdentifiers.contains($0)
        }
        
        guard let identifier = typeIdentifier else { return }
        
        NotificationCenter.default.post(
            name: .documentCoverImageUploadingEvent,
            object: ""
        )
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier
        ) { [weak self] url, error in
            // TODO: handle errr?
            url.flatMap {
                self?.uploadImage(at: $0)
            }
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

private extension ObjectCoverPickerViewModel {
    
    func uploadImage(at url: URL) {
        let localPath = url.relativePath
        
        NotificationCenter.default.post(
            name: .documentCoverImageUploadingEvent,
            object: localPath
        )
        
        uploadImageSubscription = fileService.uploadFile(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: true
        )
        .sinkWithDefaultCompletion("Cover upload image") { [weak self] uploadedImageHash in
            self?.detailsService.update(
                details: [
                    .coverType: DetailsEntry(value: CoverType.uploadedImage),
                    .coverId: DetailsEntry(value: uploadedImageHash)
                ]
            )
        }
    }
}

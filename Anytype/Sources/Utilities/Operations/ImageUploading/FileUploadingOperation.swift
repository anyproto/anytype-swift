//
//  FileUploadOperation.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore
import Combine
import BlocksModels
import UIKit

final class FileUploadingOperation: AsyncOperation {
    
    var stateHandler: FileUploadingStateHandlerProtocol?
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    
    private let itemProvider: NSItemProvider
    
    // MARK: - Initializers
    
    init(itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
        super.init()
    }
    
    override func start() {
        guard !isCancelled else {
            stateHandler?.handleImageUploadingState(.cancelled)
            return
        }
        
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            MediaPickerContentType.images.supportedTypeIdentifiers.contains($0)
        }
        
        guard let identifier = typeIdentifier else {
            stateHandler?.handleImageUploadingState(.finished(hash: nil))
            state = .finished
            return
        }
        
        stateHandler?.handleImageUploadingState(.preparing)
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier
        ) { [weak self] temporaryUrl, error in
            guard let temporaryUrl = temporaryUrl else {
                self?.stateHandler?.handleImageUploadingState(.finished(hash: nil))
                self?.state = .finished
                return
            }
            // From doc to `loadFileRepresentation(forTypeIdentifier:completionHandler:)` func:
            // This method writes a copy of the file’s data to a temporary file,
            // which the system deletes when the completion handler returns.
            //
            // In order to complete all operations with temporaryUrl before it will be deleted
            // we use `waitUntilAllOperationsAreFinished` inside `uploadFile(with:)`
            self?.uploadFile(with: temporaryUrl)
        }
        
        state = .executing
    }
    
    private func uploadFile(with temporaryUrl: URL) {
        guard !isCancelled else {
            stateHandler?.handleImageUploadingState(.cancelled)
            return
        }
        
        stateHandler?.handleImageUploadingState(
            .uploading(localPath: temporaryUrl.relativePath)
        )
        
        let hash = fileService.syncUploadImageAt(localPath: temporaryUrl.relativePath)
        
        guard !isCancelled else {
            stateHandler?.handleImageUploadingState(.cancelled)
            return
        }
        
        stateHandler?.handleImageUploadingState(
            .finished(hash: hash)
        )
        state = .finished
    }
}

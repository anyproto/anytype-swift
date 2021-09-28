//
//  ImageUploadingOperation.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore
import Combine
import BlocksModels

final class ImageUploadingOperation: AsyncOperation {
    
    var onImageUpload: ((String) -> Void)?
    
    // MARK: - Private variables
    
    private let itemProvider: NSItemProvider
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: - Initializers
    
    init(_ itemProvider: NSItemProvider) {
        self.itemProvider = itemProvider
        super.init()
    }
    
    override func start() {
        guard !isCancelled else { return }
        
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            MediaPickerContentType.images.supportedTypeIdentifiers.contains($0)
        }
        
        guard let identifier = typeIdentifier else {
            state = .finished
            return
        }
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier
        ) { [weak self] temporaryUrl, error in
            guard let temporaryUrl = temporaryUrl else {
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
        guard !isCancelled else { return }
        
        let fileUploadingOperation = FileUploadingOperation(
            url: temporaryUrl,
            contentType: .image
        )
        queue.addOperation(fileUploadingOperation)
        queue.waitUntilAllOperationsAreFinished()
        
        guard !isCancelled else { return }
        
        guard let hash = fileUploadingOperation.uploadedFileHash else {
            state = .finished
            return
        }
        
        onImageUpload?(hash)
        state = .finished
    }
}

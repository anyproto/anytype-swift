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
import UniformTypeIdentifiers

final class MediaFileUploadingOperation: AsyncOperation {
        
    // MARK: - Private variables
    
    private let itemProvider: NSItemProvider
    private let worker: MediaFileUploadingWorkerProtocol
    
    // MARK: - Initializers
    
    init(itemProvider: NSItemProvider, worker: MediaFileUploadingWorkerProtocol) {
        self.itemProvider = itemProvider
        self.worker = worker
        
        super.init()
    }
    
    override func start() {
        guard !isCancelled else {
            worker.cancel()
            return
        }
        
//        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
//            worker.contentType.supportedTypeIdentifiers.contains($0)
//        }
        
//        guard let identifier = typeIdentifier else {
//            worker.finish()
//            state = .finished
//            return
//        }
        
        worker.prepare()
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: UTType.item.identifier
        ) { [weak self] temporaryUrl, error in
            guard let temporaryUrl = temporaryUrl else {
                self?.worker.finish()
                self?.state = .finished
                return
            }

            self?.uploadFile(with: temporaryUrl)
        }
        
        state = .executing
    }
    
    private func uploadFile(with temporaryUrl: URL) {
        guard !isCancelled else {
            worker.cancel()
            return
        }
        
        worker.upload(temporaryUrl.relativePath)
        
        guard !isCancelled else {
            worker.cancel()
            return
        }
        
        worker.finish()
        state = .finished
    }
}

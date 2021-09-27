//
//  FileUploadingOperation.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore
import Combine
import BlocksModels

final class FileUploadingOperation: AsyncOperation {
    
    private(set) var uploadedFileHash: BlockActionsServiceFile.FileHash?
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    private var subscription: AnyCancellable?
    
    private let url: URL
    private let contentType: FileContentType
    
    // MARK: - Initializers
    
    init(url: URL, contentType: FileContentType) {
        self.url = url
        self.contentType = contentType
        
        super.init()
    }
    
    // MARK: - Override functions
    
    override func start() {
        guard !isCancelled else { return }
        
        subscription = fileService.uploadFile(
            url: "",
            localPath: url.relativePath,
            type: contentType,
            disableEncryption: true
        ).sink(
            receiveCompletion: { [weak self]  completion in
                switch completion {
                case .finished:
                    // Operation finish in receiveValue closure?
                    return
                case let .failure(error):
                    anytypeAssertionFailure("ImageUploadingOperation error: \(error)")
                    self?.state = .finished
                }
            },
            receiveValue: { [weak self] uploadedFileHash in
                guard let self = self else { return }
                
                self.uploadedFileHash = uploadedFileHash
                self.state = .finished
            }
        )
        
        state = .executing
    }
    
}

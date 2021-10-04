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
    
    private(set) var uploadedFileHash: Hash?
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    private var subscription: AnyCancellable?
    
    private let url: URL
    
    // MARK: - Initializers
    
    init(url: URL) {
        self.url = url
        
        super.init()
    }
    
    // MARK: - Override functions
    
    override func start() {
        guard !isCancelled else { return }
        
        subscription = fileService.uploadImageAt(localPath: url.relativePath)
            .sink(
                receiveCompletion: { [weak self]  completion in
                    switch completion {
                    case .finished:
                        self?.state = .finished
                        
                    case let .failure(error):
                        anytypeAssertionFailure("FileUploadingOperation error: \(error)")
                        self?.state = .finished
                    }
                },
                receiveValue: { [weak self] uploadedFileHash in
                    self?.handleReceiveValue(uploadedFileHash)
                }
            )
        
        state = .executing
    }
    
    private func handleReceiveValue(_ hash: Hash) {
        guard !isCancelled else { return }
        
        uploadedFileHash = hash
        state = .finished
    }
    
}

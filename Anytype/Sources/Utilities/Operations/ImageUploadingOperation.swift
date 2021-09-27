//
//  ImageUploadingOperation.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import AnytypeCore
import Combine
import BlocksModels

final class ImageUploadingOperation: AsyncOperation {
    
    private(set) var uploadedImageHash: BlockActionsServiceFile.FileHash?
    
    // MARK: - Private variables
    
    private let fileService = BlockActionsServiceFile()
    
    private var subscription: AnyCancellable?
    
    private let imageUrl: URL
    
    init(imageUrl: URL) {
        self.imageUrl = imageUrl
        
        super.init()
    }
    
    // MARK: - Override functions
    
    override func start() {
        guard !isCancelled else { return }
        
        let localPath = imageUrl.relativePath
        
        subscription = fileService.uploadFile(
            url: "",
            localPath: localPath,
            type: .image,
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
            receiveValue: { [weak self] uploadedImageHash in
                guard let self = self else { return }
                
                self.uploadedImageHash = uploadedImageHash
                self.state = .finished
            }
        )
        
        state = .executing
    }
    
}

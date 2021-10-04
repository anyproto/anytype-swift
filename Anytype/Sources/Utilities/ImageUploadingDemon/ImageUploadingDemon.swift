//
//  ImageUploadingDemon.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class ImageUploadingDemon {
    
    // MARK: - Internal variables
    
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
    // MARK: - Initializer
    
    static let shared = ImageUploadingDemon()

    // MARK: - Internal func
    
    func addOperation(_ operation: ImageUploadingOperation) {
        queue.addOperation(operation)
    }
    
}
